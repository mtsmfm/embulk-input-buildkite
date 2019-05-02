require "unofficial_buildkite_client"

module Embulk
  module Input

    class Buildkite < InputPlugin
      class Logger
        def initialize(embulk_logger)
          @embulk_logger = embulk_logger
        end

        def info(message)
          @embulk_logger.info("embulk-input-buildkite: #{message}")
        end
      end

      Plugin.register_input("buildkite", self)

      def self.transaction(config, &control)
        # configuration code:
        task = {
          "org_slug" => config.param("org_slug", :string),
          "pipeline_slug" => config.param("pipeline_slug", :string),
          "build_nums" => config.param("build_nums", :array),
          "token" => config.param("token", :string, nil),
        }

        columns = [
          Column.new(0, "id", :long),
          Column.new(1, "data", :string),
          Column.new(2, "log", :string),
          Column.new(3, "started_at", :timestamp),
          Column.new(4, "build_number", :long),
          Column.new(5, "build_data", :string),
        ]

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      # TODO
      # def self.guess(config)
      #   sample_records = [
      #     {"example"=>"a", "column"=>1, "value"=>0.1},
      #     {"example"=>"a", "column"=>2, "value"=>0.2},
      #   ]
      #   columns = Guess::SchemaGuess.from_hash_records(sample_records)
      #   return {"columns" => columns}
      # end

      def init
        # initialization code:
      end

      def run
        task['build_nums'].each do |build_num|
          logger.info("Start build_num:[#{build_num}]")

          build = client.fetch_build(number: build_num)
          build[:jobs].each do |job|
            logger.info("Start Start job_id:[#{job[:id]}]")
            log = client.fetch_log(build_number: job[:build_number], job_id: job[:id])[:output]

            page_builder.add([
              job[:id],
              job.to_json,
              log,
              job[:started_at],
              job[:build_number],
              build.to_json,
            ])

            page_builder.flush
          end
        end

        page_builder.finish

        task_report = {}
        return task_report
      end

      private

      def client
        @client ||= UnofficialBuildkiteClient.new(access_token: task["token"], org_slug: task["org_slug"], pipeline_slug: task["pipeline_slug"], logger: logger)
      end

      def logger
        @logger ||= Logger.new(Embulk.logger)
      end
    end

  end
end
