# Unfortunately, Savon cannot mock cookies.  So we'll have to run it live.
describe "Cookie handling" do
  before { Settings.session.soap_log_level = :debug }

  # Create a new space
  let(:session_vars) do
    space_id = nil
    cookie = nil
    Session.new do |bc|
      space_id = bc.create_new_space(
        :spaceName => "Birst_Command-Spec-#{SecureRandom.hex(4)}",
        :comments => "",
        :automatic => "false"
      )
      cookie = bc.auth_cookie
    end
    { :space_id => space_id, :cookie => cookie }
  end

  # Set the space id and cookie separately
  [:space_id, :cookie].each do |var|
    let(var) { session_vars[var] }
  end

  # Example data chunk to upload
  let(:data_chunk) do
    <<-EOT.unindent
    category,value
    A,1
    B,2
    C,3
    D,4
    E,5
    EOT
  end


  # Cleanup created spaces
  after do
    Session.new do |bc|
      bc.delete_space :spaceId => space_id
    end
  end


  # This test doesn't always fail if there is a cookie problem, so test it 5 times
  1.upto(5).each do
    specify "cookie should enforce login environment" do
      upload_token = nil
      Session.new auth_cookie: cookie do |bc|
        upload_token = bc.begin_data_upload(:spaceID => space_id, 
                                            :sourceName => "MyTestData"
                                           )
      end

      Session.new auth_cookie: cookie, soap_log_level: :error do |bc|
        bc.upload_data(:dataUploadToken => upload_token,
                       :numBytes => data_chunk.bytesize,
                       :data => Base64.encode64(data_chunk)
                       )
      end

      Session.new auth_cookie: cookie do |bc|
        bc.finish_data_upload(:dataUploadToken => upload_token)
      end

      Session.new auth_cookie: cookie do |bc|
        upload_complete = bc.is_data_upload_complete(:dataUploadToken => upload_token)
        puts "UPLOAD COMPLETE? #{upload_complete}"
      end

    end
  end
end
