class ImportService

  attr_reader :total_lines, :redis, :import_id

  def initialize(file)
    @file = file
    @redis = REDIS
    @total_lines = count_lines
  end

  def process
    set_redis

    CSV.foreach(@file, col_sep: ",").with_index(1) do |row, line_number|
      ProcessImportJob.perform_later(row, line_number, import_id)
    end

    update_status
  end

  def update_status
    status = @redis.hgetall(@import_id)
    status.transform_values!(&:to_i)

    Turbo::StreamsChannel.broadcast_update_to(
      @import_id,
      target: "import_status",
      partial: "imports/import_status",
      locals: { status: status }
    )
  end

  private

  def count_lines
    File.foreach(@file).count
  end

  def set_redis
    @import_id = "import_status:#{SecureRandom.uuid}"
    
    @redis.hmset(@import_id,
      'total_lines', @total_lines,
      'processed_lines', 0, 
      'number_of_errors', 0, 
      'users_created', 0, 
      'companies_created', 0, 
      'jobs_created', 0
    )
    @redis.del("#{@import_id}:errors")
  end

  def generate_error_report
    return "Nenhum erro encontrado." if @redis.llen("#{@import_id}:errors") <= 0
    errors = @redis.lrange("#{@import_id}:errors", 0, -1).map { |e| JSON.parse(e, symbolize_names: true) }

    report = "=== Relatório de erros ===\n\n"
    errors.each do |error|
      report += "Linha #{error[:line]}: "
      report += "#{error[:data]}\n"
      report += "Erros:\n"

      error[:errors].each do |message|
        report += "  - #{message}\n"
      end

      report += "\n"
    end

    report
  end
end
