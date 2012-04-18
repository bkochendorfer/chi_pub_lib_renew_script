require "rubygems"
require "mechanize"
require "pony"

@msg = ""

agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari'}
agent.follow_meta_refresh = true
agent.get('https://www.chipublib.org/mycpl/login/') do |page|

  login_info = page.form_with(:action => '/mycpl/login/') do |form|
    form.patronId = '[your_library_card_number]'
    form.zipCode = '[your_zip_code]'
  end

  agent.submit(login_info)
  page = agent.page.link_with(:href => '/mycpl/summary/#checkedOut').click
 
  date = []
  agent.page.search("div.mycpl_red td[4]").each do |td|
    date << td.content
  end

  pp page

  count = 1
  date.each do |almost_due|
    f_date = Date.strptime(almost_due, "%m/%d/%Y") - 4
    wait_for_date = DateTime.now
    if wait_for_date > f_date 
      agent.page.search("div.mycpl_red tr[#{count + 1}] a").each do |a|
        page = agent.page.link_with(:href => "#{a['href']}").click
        sleep 2
        error = agent.page.search(".errorMessage")
        if !error.nil?
          agent.page.search("div.errorMessage").each do |p|
            @msg << p.content + "\n"
          end
          agent.page.search("div.mycpl_red td[3]").each do |td|
            @msg << td.content
          end
        end
      end
    end
    count = count + 1
  end

  if !@msg.empty?
    Pony.mail({
      :from => '[your_gmail]',
      :to => '[your_gmail]',
      :subject => 'Books will be due soon',
      :body => "#{@msg}",
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => '[gmail_username]',
        :password             => '[gmail_password]',
        :authentication       => :plain,
        :domain               => "localhost.localdomain"
      }
    })
  end
end
