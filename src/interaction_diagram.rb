
class InteractionDiagram
  REQUEST_ARROW = '->'
  RESPONSE_ARROW = '-->'
  SOURCE_ON_RIGHT_NOTE_ORIENTATION = 'left'
  SOURCE_ON_LEFT_NOTE_ORIENTATION = 'right'
  BREAK_LINES_PATTERN = /[^\n].{0,100}/

  def initialize(participant_order, strict_participants)
    @strict_participants = strict_participants
    @participant_order = participant_order
    @participants = []
    @participants = @participant_order if @strict_participants
    @lines = []
  end

  def write_message(source_name, destination_name, message, isResponse)
    return if @strict_participants && !strict_participant_check(source_name, destination_name)
    add_participants(source_name, destination_name) if !@strict_participants
    @lines << "#{source_name}#{isResponse ? RESPONSE_ARROW : REQUEST_ARROW}#{destination_name}: #{break_into_lines(message.gsub(/[\r\n]/,''))}"
  end

  def write_note(source_name, destination_name, note)
    return if @strict_participants && !strict_participant_check(source_name, destination_name)
    add_participants(source_name, destination_name) if !@strict_participants
    note_lines = break_into_lines(note.gsub(/[\r\n]/,'').gsub('#','__HASH__'))
    @lines << "note #{participants_displayed_from_left_to_right(source_name, destination_name) ? SOURCE_ON_LEFT_NOTE_ORIENTATION : SOURCE_ON_RIGHT_NOTE_ORIENTATION} of #{source_name}: #{note_lines}" if !note_lines.to_s.empty?
  end

  def to_s
    @participants.map { |p| "participant " + p}.join("\n") + "\n" +
     @lines.join("\n")
  end

  private

  def add_participants(source_name, destination_name)
    @participants << source_name if !@participants.include?(source_name)
    @participants << destination_name if !@participants.include?(source_name)
    @participants.sort_by! {|p| @participant_order.find_index(p) || @participant_order.size + p.hash} # Fall back on the hash as an arbitrary stable order.
  end

  def strict_participant_check(source_name, destination_name)
    @participants.include?(source_name) && @participants.include?(destination_name)
  end

  def participants_displayed_from_left_to_right(first_participant, second_participant)
    first_participant_index = @participant_order.find_index(first_participant)
    second_participant_index = @participant_order.find_index(second_participant)

    if first_participant_index && second_participant_index
      first_participant_index < second_participant_index
    else
      true
    end
  end

  def break_into_lines(value)
    value.gsub(/\\n/,"\n").scan(BREAK_LINES_PATTERN).join("\n").gsub(/\n/,'\n')
  end
end
