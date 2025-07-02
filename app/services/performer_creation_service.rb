class PerformerCreationService
  attr_reader :errors

  def initialize
    @errors = []
  end

  def call(name:)
    return failure('Maximum number of performers (10) reached') if max_performers_reached?
    return failure('Performer name is required') if name.blank?

    performer = Performer.new(name: name)

    if performer.save
      success(performer)
    else
      failure('Failed to create performer', performer.errors.full_messages)
    end
  end

  def success?
    @success == true
  end

  def failure?
    !success?
  end

  # Public method to access the created performer
  def result
    @performer
  end

  private

  def max_performers_reached?
    Performer.count >= 10
  end

  def success(performer)
    @success = true
    @performer = performer
    self
  end

  def failure(message, details = [])
    @success = false
    @errors << message
    @errors.concat(details) if details.any?
    self
  end

  def performer
    @performer
  end
end
