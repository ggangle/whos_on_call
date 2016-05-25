class HomeController < ApplicationController
	def home
		response = HTTParty.get("https://#{ENV['BASE_DOMAIN']}.pagerduty.com/api/v1/escalation_policies/on_call", {
			headers: {
				"Authorization" => "Token token=#{ENV["PAGERDUTY_TOKEN"]}",
				},
			format: :json,
		})

		@user_records = {}

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

			primary_user = nil
			secondary_user = nil

			if ["#{ENV["CA_POLICY"]}", "#{ENV["CS_POLICY"]}"].include? id
				primary_user = on_call_users.second
				secondary_user = on_call_users.third
			else
				primary_user = on_call_users.first
				secondary_user = on_call_users.second
			end

			@user_records[id] = {
				title: ids_to_titles[id],
				primary: primary_user,
				secondary: secondary_user,
				primary_phone: get_phone(primary_user),
				# secondary_phone: phone2,
			}

		end
	end

  def get_phone(user)
		user_id = user["user"]["id"]

		response = HTTParty.get("https://#{ENV['BASE_DOMAIN']}.pagerduty.com/api/v1/users/#{user_id}/contact_methods", {
				headers: {
						"Authorization" => "Token token=#{ENV["PAGERDUTY_TOKEN"]}",
				},
				format: :json,
		})

		phone_number = nil

		response["contact_methods"].each do |contact_method|
			phone_number = contact_method["phone_number"] if contact_method.has_key?("phone_number")
		end
		phone_number
	end
end
