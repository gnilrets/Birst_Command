module BCSpecFixtures
  class << self

    def login_token
      "46a87e10b37e21653186ffe0973f54ae"
    end

    def login
      <<-EOT.unindent
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <soap:Body>
          <LoginResponse xmlns="http://www.birst.com/">
            <LoginResult>#{login_token}</LoginResult>
          </LoginResponse>
        </soap:Body>
      </soap:Envelope>
      EOT
    end

    def logout
      <<-EOT.unindent
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <soap:Body>
          <LogoutResponse xmlns="http://www.birst.com/"/>
        </soap:Body>
      </soap:Envelope>
      EOT
    end
    
    def list_spaces
      <<-EOT.unindent
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <soap:Body>
          <listSpacesResponse xmlns="http://www.birst.com/">
            <listSpacesResult>
              <UserSpace>
                <name>My_First_Space</name>
                <owner>user@example.com</owner>
                <id>b016c5c7-00ad-413a-a058-db78edef2961</id>
              </UserSpace>
              <UserSpace>
                <name>My_Second_Space</name>
                <owner>user@example.com</owner>
                <id>b7f3df39-438c-4ec7-bd29-489f41afde14</id>
              </UserSpace>
            </listSpacesResult>
          </listSpacesResponse>
        </soap:Body>
      </soap:Envelope>
      EOT
    end

    def list_users_in_space
      <<-EOT.unindent
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <soap:Body>
          <listUsersInSpaceResponse xmlns="http://www.birst.com/">
            <listUsersInSpaceResult>
              <string>user@example.com</string>
              <string>myname@example.com</string>
              <string>coolbeans@example.com</string>
            </listUsersInSpaceResult>
          </listUsersInSpaceResponse>
        </soap:Body>
      </soap:Envelope>
      EOT
    end

  end
end
