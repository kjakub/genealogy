module Genealogy
  module SpouseMethods
    extend ActiveSupport::Concern

    include Constants

    # add method
    def add_current_spouse(obj)
      raise ArgumentError, "Expected #{self.genealogy_class} object. Got #{obj.class}" unless obj.class.respond_to?(:genealogy_enabled)
      raise IncompatibleRelationshipException, "#{obj} can't be spouse of #{self}" unless eligible_current_spouses.include? obj

      if perform_validation
        self.current_spouse = obj
        obj.current_spouse = self
        transaction do
          obj.save!
          save!
        end
      else
        transaction do
          self.update_attribute(:current_spouse,obj)
          obj.update_attribute(:current_spouse,self)
        end
      end

    end

    # remove method
    def remove_current_spouse
      if perform_validation
        ex_current_spouse = current_spouse
        current_spouse.current_spouse = nil
        self.current_spouse = nil
        transaction do
          ex_current_spouse.save!
          save!
        end
      else
        transaction do
          current_spouse.update_attribute(:current_spouse,nil)
          self.update_attribute(:current_spouse,nil)
        end
      end
    end

    # query methods
    def eligible_current_spouses
      self.genealogy_class.send("#{OPPOSITESEX[sex_to_s.to_sym]}s") - spouses
    end

  end
end