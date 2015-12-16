defmodule Rumbl.UserView do 
	use Rumbl.Web, :view
	alias Rumbl.User

	def first_name(%User{name: name}) do
		cond do 
			is_binary name -> name|>String.split(" ")|>Enum.at(0)
			true -> ""			
		end 		
	end	
end