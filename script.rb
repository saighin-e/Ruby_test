require 'watir'
require 'pry-byebug'
require 'pp'
require 'nokogiri'

#Create a Transaction class that has the following fields:

class Transactions
	attr_accessor :date, :description, :amount, :currency
end


#Write a script that signs into VictoriaBank's "Da" interface. The script should ask the user to input the LOGIN, PASSWORD, CAPTCHA using the gets method.
browser = Watir::Browser.new
browser.goto 'https://da.victoriabank.md/frontend/auth/userlogin?execution=e1s1&locale=ru'

puts "Please enter the login: "
LOGIN = gets
puts "Please enter the password:"
PASSWORD = gets
puts "Please enter captcha: "
CAPTCHA = gets

browser.text_field(name: "Login").set(LOGIN)
browser.text_field({type: "password"}).set(PASSWORD)
browser.text_field({name: "captchaText"}).set(CAPTCHA)

#Write a script that navigates through the Victoriabank page and prints an array of objects in the following way:
until browser.span(:class, "owwb-ws-header-user-name").exists? do sleep 1 end
doc = Nokogiri::HTML(browser.html)

data = {"accounts":
  [
    {
      "name": doc.css("span.owwb-ws-header-user-name").text,
      "balance": doc.css("span.owwb-cs-slide-list-amount-value.jsMaskedElement").first().text,
      "currency": doc.css("span.owwb-cs-slide-list-amount-currency").first().text,
      "nature": "checking",
      "transactions": []
    }
  ]
}

browser.a(:name, "main_menu_CP_HISTORY").click()
browser.a(:name, "sub_menu_{item.code}").click()

#Extend your script to output the list of transactions for the last two months. Use the date picker on VictoriaBank's website
browser.execute_script('document.getElementById("owwb_ws_USER_PROPERTY_DATE_FROM").value = "2017-03-01"')
browser.form(:id, "owwb_ws_serviceRefreshForm").submit()

#Extend your script in such a way that the stored JSON account will contain a list of Transactions. Example of output:
doc = Nokogiri::HTML(browser.html)
date_current = ''
doc.css("li.owwb_ws_statementItem").each do |li|
	transaction = Transactions.new
  if li.css(".owwb-ws-statement-item-date div.owwb-cs-has-tooltip").length != 0
    date_current = date = li.css(".owwb-ws-statement-item-date div.owwb-cs-has-tooltip").text.split("\n")[1].strip()
  else
    date = date_current
  end

	time = li.css(".owwb-ws-statement-item-time").text
	transaction.date = "#{date}T#{time}Z"
	transaction.description = li.css(".owwb-ws-statement-item-title-wrapper div.owwb_ws_statementItemTitle").text.split("\n")[1].strip()
	transaction.amount = li.css("span.jsMaskedElement").first().text
	transaction.currency = li.css("span.owwb-ws-statement-item-amount-currency").first().text
	data[:accounts][0][:transactions].push(transaction)
end

pp data
