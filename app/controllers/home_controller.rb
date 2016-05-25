class HomeController < ApplicationController

	def home

		response = HTTParty.get("https://#{ENV['BASE_DOMAIN']}.pagerduty.com/api/v1/escalation_policies/on_call", {
			headers: {
				"Authorization" => "Token token=#{ENV["PAGERDUTY_TOKEN"]}",
				},
			format: :json,
		})

		@collected = {}

		ids_to_titles = {
			"#{ENV["CA_POLICY"]}" => "CA/UW",
			"#{ENV["CS_POLICY"]}" => "CS",
			"#{ENV["DEVOPS_POLICY"]}" => "DevOps",
			"#{ENV["IT_POLICY"]}" => "IT",
			"#{ENV["OPS_POLICY"]}" => "Ops",
			"#{ENV["PM_POLICY"]}" => "PM",
		}
	
		response["escalation_policies"].each do |policy|
			id = policy["id"]
			on_call_users = policy["on_call"]

			if ["#{ENV["CA_POLICY"]}", "#{ENV["CS_POLICY"]}"].include? id
				@collected[id] = {
				title: ids_to_titles[id],
				primary: on_call_users.second,
				secondary: on_call_users.third,
			}
			else
				@collected[id] = {
					title: ids_to_titles[id],
					primary: on_call_users.first,
					secondary: on_call_users.second,
				}
			end

		end

		# user_response = HTTParty.get("https://#{ENV['BASE_DOMAIN']}.pagerduty.com/api/v1/users/#{user_id}/contact_methods", {
		# 		headers: {
		# 				"Authorization" => "Token token=#{ENV["PAGERDUTY_TOKEN"]}",
		# 		},
		# 		format: :json,
		# })
    #
		# user_response.each do |contact|
    #
		# 				@phone = contact[1]["phone_number"]
    #
		# end

	end

end