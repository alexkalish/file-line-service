module Process
  class PreProcessFile 

    def self.run(file_path)

      file_meta = Logical::FileMetadata.generate(file_path)

      ap file_meta.to_json

    end

  end
end
