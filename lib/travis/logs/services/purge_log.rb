require "travis/logs/helpers/metrics"
require "travis/logs/helpers/s3"
require "travis/logs/sidekiq"
require "travis/logs/sidekiq/archive"

module Travis
  module Logs
    module Services
      class PurgeLog
        include Helpers::Metrics

        METRIKS_PREFIX = "logs.purge"

        def self.metriks_prefix
          METRIKS_PREFIX
        end

        def initialize(log_id, storage_service = nil, database = nil, archiver = nil)
          @log_id = log_id
          @storage_service = storage_service || Helpers::S3.new
          @database = database || Travis::Logs.database_connection
          @archiver = archiver || ->(log_id) { Sidekiq::Archive.perform_async(log_id) }
        end

        def run
          if db_content_length_empty?
            process_empty_log_content
          else
            process_log_content
          end
        end

        private

        def db_content_length_empty?
          content_length_from_db.nil? || content_length_from_db == 0
        end

        def process_empty_log_content
          if content_length_from_s3.nil?
            Travis.logger.warn("[warn] log with id:#{@log_id} missing in database or on S3")
            mark("log.content_empty")
          else
            measure("already_purged") do
              @database.transaction do
                @database.mark_archive_verified(@log_id)
                @database.purge(@log_id)
              end
            end
            Travis.logger.info("log with id:#{@log_id} was already archived, has now been purged")
          end
        end

        def process_log_content
          if content_lengths_match?
            measure("purged") do
              @database.purge(@log_id)
            end
            Travis.logger.info("log with id:#{@log_id} purged from db (db and s3 content lengths match content_length:#{content_length_from_db})")
          else
            measure("requeued_for_achiving") do
              @database.mark_not_archived(@log_id)
              @archiver.call(@log_id)
            end
            Travis.logger.info("log with id:#{@log_id} queued to be reachived as db and s3 content lengths don't match (db:#{content_length_from_db} s3:#{content_length_from_s3})")
          end
        end

        def content_lengths_match?
          content_length_from_db == content_length_from_s3
        end

        def content_length_from_db
          log[:content_length]
        end

        def content_length_from_s3
          @content_length_from_s3 ||= begin
            measure("check_content_length") do
              @storage_service.content_length(log_url)
            end
          rescue
            mark("check_content_length.failed")
          end
        end

        def log
          unless defined?(@log)
            @log = @database.log_content_length_for_id(@log_id)
            unless @log
              Travis.logger.warn("[warn] log with id:#{@log_id} could not be found")
              mark("log.not_found")
            end
          end

          @log
        end

        def log_url
          "http://#{Travis.config.s3.hostname}/jobs/#{log[:job_id]}/log.txt"
        end
      end
    end
  end
end
