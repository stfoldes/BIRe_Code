% Send_Email(Email)
% Stephen Foldes
% 03-25-08
%
% This function sends an email...pretty simple. Below is an example with a valid email address for sending (as of 03-16-11)
%
% Input structure example:
% Email.from = 'PittBMI@gmail.com'; % sending email address
% Email.password = [80 105 116 116 66 77 73 49 57]; % slight encryption by turning string into numbers using: single('password');
% Email.stmp_server='smtp.gmail.com'; % SMTP server address (depends on your location), usually 'smtp-server.neo.rr.com' or 'smtp.case.edu' or 'smtp.gmail.com';
% Email.to='xxx@gmail.com';
% Email.subject='Subject header'; % you can use the command "mfilename" to put in the current mfiles name, also datestr(now,'yy-mm-dd_HHMM') for current time
% Email.body='Email body';  % 10 in the body is a carriage return (just 10, not a string).
% Email.attachment = ['C:/Research/AwesomeResults.txt']; % string of file with location (leave out or put as [])
%
% UPDATES
% 03-16-11 SF: Combine with Send_Email_Attachment to allow for attachements. Also won't crash out if there was an error.

function Send_Email(Email)

%% Set up email
try
    % Then this code will set up the preferences properly:
    setpref('Internet','E_mail',Email.from);
    setpref('Internet','SMTP_Server',Email.stmp_server);
    setpref('Internet','SMTP_Username',Email.from);
    setpref('Internet','SMTP_Password',char(Email.password));
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    %% Send the email
    if isfield(Email,'attachment') & ~isempty(Email.attachment)
        try
            sendmail(Email.to,Email.subject,Email.body,Email.attachment)
            disp('Email Sent Successfully')
        catch
            disp('ERROR WITH SENDING EMAIL: NO ATTACHMENT WAS SENT')
            Email.body = ['ERROR WITH SENDING EMAIL: NO ATTACHMENT WAS SENT' 10 Email.body];
            sendmail(Email.to,Email.subject,Email.body)
        end
    else
        sendmail(Email.to,Email.subject,Email.body)
        disp('Email Sent Successfully')
    end
    
catch
    disp('ERROR WITH SENDING EMAIL: NO EMAIL WAS SENT')
end


