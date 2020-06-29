module Batch
  class Locked < StandardError
  end

  class Base
    def self.run(*arguments)
      synchronized do
        new.run(*arguments)
      end
    rescue Batch::Locked
      puts '** other proccess executing **'
    end

    def self.synchronized(lock_file = self.lock_file_path,
                          lock_flags = File::LOCK_EX|File::LOCK_NB)
      File.open(lock_file, 'w') do |lock_file|
        if lock_file.flock(lock_flags)
          yield
        else
          raise Batch::Locked, "#{lock_file.path} is locked."
        end
      end
    end

    def self.lock_file_path(name = self.name.underscore)
      "/tmp/#{name}_#{Process.uid}.lock"
    end

    # instance methods
    def synchronized(lock_file = self.lock_file_path,
                     lock_flags = File::LOCK_EX|File::LOCK_NB)
      self.class.synchronized(lock_file, lock_flags) do
        yield
      end
    end
    def lock_file_path(name = self.class.name.underscore)
      self.class.lock_file_path(name)
    end
  end
end
