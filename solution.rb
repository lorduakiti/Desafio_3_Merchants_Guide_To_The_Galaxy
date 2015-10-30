=begin
	Title of the program: Challenge 3: Merchant's Guide To The Galaxy
	Author: Uákiti Pires
	Contact: lorduakiti@gmail.com
	Version: 1.0.0

	Description:  
	This program help me to buying and selling over the galaxy, 
	because the operations demands requires convert numbers and units.

=end
	
module MerchantGuideConversion

	class FileInput
		attr_accessor :file_input_name
		attr_accessor :file_input_text
		
		def initialize
			@file_input_name = ""
			@file_input_text = ""
			
			if ARGV.empty?
				puts "File note found!"
				return
			end
		end

		def get_file_input
			@file_input_name = ARGF.filename
			@file_input_text = ARGF.read
		end
	end

	class FileOutput
		attr_accessor :file_output_name
		attr_accessor :file_output_text
		
		def initialize
			@file_output_name = ""
			@file_output_text = ""
		end

		def set_file_output(name="output.txt",text)
			@file_output_name = name
			@file_output_text = text.join("\n")

			if  File.exists? @file_output_name
				File.rename @file_output_name, @file_output_name.sub(".txt", "") + "-" + Time.now.strftime("%Y%m%d-%H%M%S") + ".txt"
			end

			# Create a new file output
			File.new(@file_output_name,  "w+")

			# Open file output
			File.open(@file_output_name, "w+" ) do |f| 
				f << @file_output_text
			end
		end
	end

	class Conversion
		attr_accessor :roman_numerals
		attr_accessor :galaxy_symbols
		attr_accessor :sell_items


		def initialize
			@roman_numerals = {
				"I" => 1,
				"V" => 5,
				"X" => 10,
				"L" => 50,
				"C" => 100,
				"D" => 500,
				"M" => 1000
			}
			@galaxy_symbols = {}
			@sell_items = {}
		end

		def roman_conversion(roman_number)
			# Validate number

			if roman_number =~ /IIII|XXXX|CCCC|MMMM/
				puts "Error roman number conversion! [Repeat sequence more 4 times I, X, C or M]"
				return
			elsif roman_number =~ /DD|LL|VV/
				puts "Error roman number conversion! [Repeat sequence D, L or V]"
				return
			end

			# Declare variables
			vars = roman_number.split ""
			nums = []

			# Remove empty elements from the array.
			vars.delete_if{|e| (e.length == 0) || (e == " ")}

			# Display each value to the console.
			v_ant = ""
			n = aux = aux_ant = 0
			
			vars.reverse.each do |v|
			
				aux = @roman_numerals[v]

				# Check de rules for only one small-value symbol may be subtracted from any large-value symbol.
				if (aux < aux_ant) && (n != 0)					
					if (v == "I") && (v_ant.scan(/V|X/).empty?)
						puts "Error roman number conversion! [Decrement I not in V or X]"
						return
					elsif (v == "X") && (v_ant.scan(/L|C/).empty?)
						puts "Error roman number conversion! [Decrement X not in L or C]"
						return
					elsif (v == "C") && (v_ant.scan(/D|M/).empty?)
						puts "Error roman number conversion! [Decrement C not in D or M]"
						return
					elsif !v.scan(/V|L|D/).empty?
						puts "Error roman number conversion! [Decrement V, L or D]"
						return
					end

					aux = -1 * aux
				end

				nums.push aux 
			    
			    aux_ant = aux
			    v_ant = v
			    n += 1
			end
			nums.reverse!
			nums.inject(0, :+)
		end


		def galaxy_conversion(galaxy_symbol)
			symbol = galaxy_symbols[galaxy_symbol]

			if !symbol.nil? && !symbol.empty?
				roman_num = @roman_numerals.keys.select { |s| s.match(symbol) }.join
			else
				roman_num = ""
			end
		end

	end

	class ProcessText
		def process_text_line (text_input)
			if text_input == ""
				puts "Error file empty!"
				return
			end

			text_lines_output = []

			numConversion = Conversion.new
			aux_roman_nums = numConversion.roman_numerals.keys.join("|")

			type_line = aux = ""  # conversion, proposition, question or undefined
			aux_prop = aux_items = aux_vals = []
			aux_sell_item = {}


			text_input.each_line do |line|
				line.delete!("\n")

				if line =~ /\?/
					type_line = "question"
				elsif line =~ /Credits/
					type_line = "proposition"
				elsif line =~ / is /
					type_line = "conversion"
				else
					type_line = "undefined"
				end

				case type_line
					when "conversion"
						aux_items = line.split " is "
						numConversion.galaxy_symbols.merge!(aux_items[0]=>aux_items[1])

					when "proposition"
						aux_prop = line.split " is "
						aux_items = aux_prop[0].split " "
						aux_vals = aux_prop[1].split " "

						sell_item = aux_gs = aux_rn = roman_number = ""
						arabic_number = 0

						aux_items.each do |i|
							roman_number = numConversion.galaxy_conversion i

							if roman_number == ""
								sell_item = i 
							else								
								aux_gs += i + " "
								aux_rn += roman_number
							end
						end

						if aux_rn == ""
							puts "Error proposition process! [Roman numeral does not correspond]"
							return
						end
						arabic_number = numConversion.roman_conversion aux_rn
						aux_sell_item = {"galaxy"=>aux_gs, "roman"=>aux_rn, "arabic"=>arabic_number, "quotation"=>aux_vals[0]}

						numConversion.sell_items.merge!(sell_item=>aux_sell_item)

					when "question"
						if line =~ / is /
							aux_prop = line.split " is "
							aux_items = aux_prop[1].split " "
							aux_items.delete "?"

							sell_item = aux_gs = aux_rn = roman_number = ""
							arabic_number = 0

							aux_items.each do |i|
								roman_number = numConversion.galaxy_conversion i
								if roman_number == ""
									sell_item = i 
								else								
									aux_gs += i + " "
									aux_rn += roman_number
								end
							end

							if aux_rn == ""
								puts "Error question process! [Roman numeral does not correspond]"
								return
							end

							arabic_number = numConversion.roman_conversion aux_rn

							if arabic_number.nil?
								puts "Error question process! [Arabic numeral does not correspond]"
								return
							end
							value_quote = 0

							if aux_prop[0]=="how much"
								text_lines_output.push "#{aux_gs} is #{arabic_number}".squeeze
							elsif aux_prop[0]=="how many Credits"
								if numConversion.sell_items[sell_item]["arabic"].to_i == 0
									puts "Error question process! [Zero Division]"
									return
								end

								value_quote = (arabic_number * numConversion.sell_items[sell_item]["quotation"].to_i) / numConversion.sell_items[sell_item]["arabic"].to_i
								text_lines_output.push "#{aux_gs} #{sell_item} is #{value_quote} Credits".squeeze
							end
						else
							text_lines_output.push "I have no idea what you are talking about"
						end
					else
						text_lines_output.push "I have no idea what you are talking about" 
				end
			end

			text_lines_output
		end
	end

	text_input = FileInput.new
	text_input.get_file_input

	text_output = ProcessText.new
	text_output_processed = text_output.process_text_line(text_input.file_input_text)

	file_output = FileOutput.new

	file_output.set_file_output("output.txt", text_output_processed)
end