require "test_birst_command"

class Test_cookie < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
    @new_space_id = nil
  end

  def teardown
    Session.start do |bc|
      bc.delete_space :spaceId => @new_space_id
    end
  end

  def test_cookie_using_a_copy_command
    test_options = Birst_Command::Config.options[:test][:test_copy_space]

    session_cookie = nil
    job_token = nil
    Session.start do |bc|
      @new_space_id = bc.create_new_space :spaceName => "test_copy_space",
                                          :comments => "",
                                          :automatic => "false"

      puts "#{JSON.pretty_generate bc.list_spaces}"
      job_token = bc.copy_space :spFromID => test_options[:from_space_id],
                                :spToID => @new_space_id,
                                :mode => "copy",
                                :options => "data;settings-permissions;settings-membership;repository;birst-connect;custom-subject-areas;dashboardstyles;salesforce;catalog;CustomGeoMaps.xml;spacesettings.xml;SavedExpressions.xml;DrillMaps.xml;connectors;datastore-aggregates;settings-basic"

      session_cookie = bc.auth_cookies
    end

    puts "COOKIE COOKIE: #{session_cookie}"

    i = 0
    loop do
      i += 1
      if i < 60
        is_job_complete = false
        Session.start use_cookie: session_cookie do |bc|
          is_job_complete = bc.is_job_complete :jobToken => job_token
        end
        puts "COMPLETE? #{is_job_complete}"

        sleep 1
        break if is_job_complete
      else
        raise "Copy job timed out"
      end

    end


    # This test sucks, but it will fail if the cookies don't work
    assert_equal 36, @new_space_id.length, "Got an invalid space id #{@new_space_id}"
  end
end

