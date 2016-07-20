namespace :seed do
  if !Rake::Task.task_defined?("seed:migrate")
    desc "Run new data migrations."
    task :migrate => :environment do
      p "Loading data to ...."
      if ENV['S3I_DOMAIN_CODE'].blank? || ENV['S3I_DOMAIN_ROOT'].blank?
        msg="FI4ERROR: ENV['S3I_DOMAIN_CODE'] or ENV['S3I_DOMAIN_ROOT'] is/are not defined..."
        p msg
        raise msg
      end

      begin
        S3i_Domain.connect ENV['S3I_DOMAIN_CODE'], ENV['S3I_DOMAIN_ROOT']
      rescue
        p "S3i_Domain.current_domain=#{Rails.configuration.database_configuration["production"]} saas=#{Sinai.is_saas?} standalone=#{Sinai.is_standalone?}"
        p "S3i_Domain.first=#{S3i_Domain.first.attributes}"
        msg= "FI4ERROR: I've found errors in connect to #{ENV['S3I_DOMAIN_CODE']}/#{ENV['S3I_DOMAIN_ROOT']}. Cancelling load data..."
        p msg
        raise msg
      end
      p "S3i_Domain.current_domain=#{S3i_Domain.current_domain.url}"
      p "MODE installed is SAAS" if Sinai.is_saas?
      p "MODE installed is STANDALONE" if Sinai.is_standalone?
      p "Loading data to #{ENV['S3I_DOMAIN_CODE']}/#{ENV['S3I_DOMAIN_ROOT']}...."

      SeedMigration::Migrator.run_migrations(ENV['MIGRATION'])
    end
  end

  if !Rake::Task.task_defined?("seed:rollback")
    desc "Revert last data migration."
    task :rollback => :environment do
      SeedMigration::Migrator.rollback_migrations(ENV["MIGRATION"], ENV["STEP"] || ENV["STEPS"] || 1)
    end
  end

  namespace :migrate do
    if !Rake::Task.task_defined?("seed:migrate:status")
      desc "Display status of data migrations."
      task :status => :environment do
        p "Loading data to ...."
        if ENV['S3I_DOMAIN_CODE'].blank? || ENV['S3I_DOMAIN_ROOT'].blank?
          msg="FI4ERROR: ENV['S3I_DOMAIN_CODE'] or ENV['S3I_DOMAIN_ROOT'] is/are not defined..."
          p msg
          raise msg
        end

        begin
          S3i_Domain.connect ENV['S3I_DOMAIN_CODE'], ENV['S3I_DOMAIN_ROOT']
        rescue
          p "S3i_Domain.current_domain=#{Rails.configuration.database_configuration["production"]} saas=#{Sinai.is_saas?} standalone=#{Sinai.is_standalone?}"
          p "S3i_Domain.first=#{S3i_Domain.first.attributes}"
          msg= "FI4ERROR: I've found errors in connect to #{ENV['S3I_DOMAIN_CODE']}/#{ENV['S3I_DOMAIN_ROOT']}. Cancelling load data..."
          p msg
          raise msg
        end
        p "S3i_Domain.current_domain=#{S3i_Domain.current_domain.url}"
        p "MODE installed is SAAS" if Sinai.is_saas?
        p "MODE installed is STANDALONE" if Sinai.is_standalone?
        p "Loading data to #{ENV['S3I_DOMAIN_CODE']}/#{ENV['S3I_DOMAIN_ROOT']}...."

        SeedMigration::Migrator.display_migrations_status
      end
    end
  end
end
