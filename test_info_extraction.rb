require 'stanford-core-nlp'
require 'monetize'

organization_array = []
location_array = []
person_array = []
money_array = []

interesting_tags = [
  "ORGANIZATION",
  "LOCATION",
  "PERSON",
  "MONEY"
]

paragraph = "Manchester United aren’t faffing around either." + 
  " They’ll be making enquiries for the £22m Sevilla striker" + 
  " Carlos Bacca, and the £21m Benfica midfielder Nicolás Gaitán." + 
  " Liverpool are also sniffing around the latter, hoping to" + 
  " hijack the move, but consider Memphis Depay and let us move" + 
  " on without further comment."

pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
paragraph = StanfordCoreNLP::Annotation.new(paragraph)
pipeline.annotate(paragraph)

combined_text = ""
prev_tag = ""

define_method :push_to_array do |tag, combined_text, offset_start, offset_end|
  combined_text_hash = {}

  if tag == "MONEY"  
    combined_text_hash = {
      "text" => Monetize.parse(combined_text.sub("£", " GBP ").sub("€", " EUR ")).format,
      "offset_start" => offset_start,
      "offset_end" => offset_end
      "tag" => tag
    }
  else 
    combined_text_hash = {
      "text" => combined_text,
      "offset_start" => offset_start,
      "offset_end" => offset_end
      "tag" => tag
    }
  end

  case tag
  when "ORGANIZATION"
    organization_array.push(combined_text_hash)
  when "LOCATION"
    location_array.push(combined_text_hash)
  when "PERSON"
    person_array.push(combined_text_hash)
  when "MONEY"
    money_array.push(combined_text_hash)
  end
end

offset_start = ""
offset_end = ""

paragraph.get(:sentences).each do |sentence|
  sentence.get(:tokens).to_a.each_with_index do |token, index|
    text = token.get(:original_text).to_s
    tag = token.get(:named_entity_tag).to_s

    if interesting_tags.include?(tag)
      if prev_tag == ""
        offset_start = token.get(:character_offset_begin).to_s
        combined_text = text
      else 
        if prev_tag == tag
          combined_text += " " + text
        else
          offset_end = token.get(:character_offset_begin).to_s
          push_to_array(prev_tag, combined_text, offset_start, offset_end)
          combined_text = text
          offset_start = token.get(:character_offset_begin).to_s
        end
      end
    else 
      offset_end = token.get(:character_offset_begin).to_s
      push_to_array(prev_tag, combined_text, offset_start, offset_end)
      combined_text = ""
      offset_start = token.get(:character_offset_begin).to_s
    end
    
    prev_tag = tag
  end
end

f = File.new("test_ner_out.txt", "w")
f.write("######### ORIGINAL TEXT #########\n")
f.write(paragraph)
f.write("\n\n")
f.write("######### ORGANIZATION #########\n")
f.write(organization_array.join("\n"))
f.write("\n")
f.write("######### LOCATION #########\n")
f.write(location_array.join("\n"))
f.write("\n")
f.write("######### PERSON #########\n")
f.write(person_array.join("\n"))
f.write("\n")
f.write("######### MONEY #########\n")
f.write(money_array.join("\n"))
f.write("\n")
f.close
