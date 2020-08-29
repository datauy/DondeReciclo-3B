class ApplicationMailer < ActionMailer::Base
  default from: 'contacto@dondereciclo.uy', host: 'dondereciclo.uy'
  layout 'mailer'
end
