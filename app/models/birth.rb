class Birth < ActiveRecord::Base
	belongs_to :child, :class_name => "Person", :foreign_key => "child"

	validate :parents_born_before_child

	def father
		if father_id
			Person.find(father_id)
		else
			nil
		end
	end

	def mother
		if mother_id
			Person.find(mother_id)
		else
			nil
		end
	end

	private

		def parents_born_before_child
			## TODO: Might want to add a setting to check that it's at least a
			## certain number of years before
			if father.present? && 
				father.birth.date.present? && 
				date.present? &&
				father.birth.date >= date 
				errors.add(:father, "can't be born before child")
			end
			if mother.present? && 
				mother.birth.date.present? && 
				date.present? &&
				mother.birth.date >= date
				errors.add(:mother, "can't be born before child")
			end
		end
end