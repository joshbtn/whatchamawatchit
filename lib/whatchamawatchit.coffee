# Includes
http = require 'http'
cli = require 'cli'
crypto = require 'crypto'
jsdom = require 'jsdom'
simplesmtp = require 'simplesmtp'
stream = require 'stream'
fs = require 'fs'
MailComposer = require('mailcomposer').MailComposer;

# Global Vars
url = "http://www.microsoft.com/en-us/download/details.aspx?id=36229"
elementId = "ctl00_ctl20_ColumnRepeater_ctl00_RowRepeater_ctl01_CellRepeater_ctl00_ctl01";
SMTP_PORT = 25;
SMTP_HOST  = "mail.hirtlecallaghan.com"
doc = null
win = null
options = cli.parse()
lastHash = "";
firstRun = true

# SMTP Request listener
#smtpRequestListener = (req) ->
    #req.pipe process.stdout
    
    #output = ""
    
    #req.on 'data', (chunk) ->
     #   output += chunk
    
    #req.on 'end', () ->
    #    console.log output
    #    return
    
    #req.accept()
    #return

# Set up email server
#smtpServer = simplesmtp.createSimpleServer {debug: true}, smtpRequestListener 
#smtpServer.listen(SMTP_PORT)

sendEmail = () ->
    # Set up email client
    mail = new MailComposer
    mail.addHeader "x-mailer", "Nodemailer 1.0"
    mail.setMessageOption
        from: "crm@example.com",
        to: "jbennett@hirtlecallaghan.com",
        subject: "CRM 2011 rollup 12 might be available",
        body: "CRM 2011 rollup 12 might be available!",
        html: "<b>CRM 2011 rollup 12 might be available!</b>"

    smtpClientPool = simplesmtp.createClientPool SMTP_PORT, SMTP_HOST
        
    smtpClientPool.sendMail mail, (error, res) ->
    console.log error, res
    return
    
watchPage = (test) ->
    get = http.get url, (res) ->
        res.setEncoding 'utf8'
       
        output = ""
        
        res.on 'data', (chunk) ->
            output += chunk
        
        res.on 'end', () ->
            doc = jsdom.jsdom(output)
            win = doc.createWindow()
            
            md5hash = crypto.createHash "md5"
            
            # Target an elementn to hash
            diffElementString = doc.getElementById(elementId).innerHTML;
            md5hash.update if diffElementString? then diffElementString else ""
            
            newHash = md5hash.digest('hex')
            
            if newHash != lastHash and !firstRun
                console.log "The page has been updated!"
                sendEmail()
                lastHash = md5hash
            else if firstRun
                firstRun = false
            
            return
        
        return
    

#setInterval watchPage, 10000
watchPage()