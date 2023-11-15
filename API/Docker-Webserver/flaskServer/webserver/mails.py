import hashlib
import smtplib
from flask import make_response
from base64 import b64encode, b64decode
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from utils import writeLog
from email import encoders
from utils import log


def send_mail(content, subject, receivers):

    sender = "ventas@minervatech.uy"

    try:
        msg = MIMEText(content, 'html')

        msg['Subject'] = subject
        msg['From'] = sender
        msg['To'] = receivers
        
        s = smtplib.SMTP_SSL(host = 'mail.minervatech.uy', port = 465)
        s.login(user = sender, password = 'cocoholis2015.')
        s.sendmail(sender, receivers, msg.as_string())
        s.quit()
            
    except Exception as e:
        log(f"Error en sendMail: {e}")