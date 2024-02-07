module ApplicationHelper
	def flash_class(level)
	    return "alert alert-dismissible alert-"+level.to_s
	end

	def source_category_concatenate(description, predecessor)

	 pre=-1
	        leaf_source=(" . "+description)
	        @source=SourceCategory.find(predecessor)
	        until  pre==0 do
	          leaf_source=" . " + @source.description+leaf_source 
	          if pre!=nil
	            @source=SourceCategory.find_by_id(@source.predecessor)
	            if@source==nil
	              pre=0
	            else
	              pre=@source.predecessor
	            end
	          else
	            pre=0
	          end
	        end
	        leaf_source[0]=""
	        leaf_source[0]=""
	        leaf_source[0]=""

	return leaf_source
	
	end

	def number_to_indian_currency(number)
		"₹#{number.to_s.gsub(/(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/, "\\1,")}" 
	end

	def comma_separated(number)
		"#{number.to_s.gsub(/(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?/, "\\1,")}" 
	end

end
