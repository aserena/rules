ActiveAdmin::FormBuilder.class_eval do
  def has_rules
    self.inputs 'Rules' do
      self.semantic_fields_for :rule_set do |rules_rule_set_form|
        rules_rule_set_form.has_many :rules do |rules_rule_form|
          rules_rule_form.input :lhs_parameter, :label => 'Left hand side', collection: rules_parameter_collection(rules_rule_form.object.rule_set)
          rules_rule_form.input :evaluator, :as => :select, :collection => Rules.evaluators.map {|key, evaluator| [evaluator.name, key] }.sort_by {|name, key| name }
          rules_rule_form.input :rhs_parameter, :label => 'Right hand side'
        end
        rules_rule_set_form.input :evaluation_logic, :as => :select, :label => 'Must match', collection: [['All Rules', 'all'], ['Any Rules', 'any']]
      end
    end
  end

  def rules_parameter_collection(rule_set)
    @rules_parameter_collection ||= Rules.constants.merge(rule_set.try(:attributes) || {}).map {|key, const| [const.name, key] }
  end
end

ActiveAdmin::Views::Pages::Show.class_eval do
  def show_rules
    panel "Rules" do
      div resource.rule_set.evaluation_logic == 'any' ? 'Must match any rule' : 'Must match all rules'
      table_for resource.rule_set.rules do |rule|
        column('Left hand side') { |rule| rule.lhs_parameter_object.to_s.titleize }
        column('Condition') { |rule| rule.get_evaluator }
        column('Right hand side') { |rule| rule.rhs_parameter_value.to_s }
      end
    end
  end
end
