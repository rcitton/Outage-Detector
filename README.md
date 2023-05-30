# Outage Detector for Docker or Podman
Simple module meant to notify user if a power outage has occured or if the internet has been down.

## What it does

At every run it writes to a text file timestamps for power and internet, whether the last run was scheduled or at boot and the last calculated periodicity.

If the script was run after a boot up, it will assume there was a power outage (the system is meant to run 24/7, for example a Raspberry Pi Zero) and send a notification, approximating the power outage duration through the last known timestamp and calculated periodicity of the runs.

Internet downtime is detected if the 2 timestamps written to the file differ and the downtime is approximated again through the calculated periodicity. It is possible that an internet downtime is missed if the script is run too rarely.

### Run with Docker or Podman

1. Build the container.

    ```
    docker build -t rcitton/outage_detector ./
    ```

2. Run the container 

    ### a. leveraging on GMail notification
    ```
    docker run -d -t --name=outage_detector \
    -e 'NOTIFICATION_TYPE'='mail' \
    -e 'SENDER_MAIL_ADDRESS'='<sender mail address>' \
    -e 'RECEIVER_MAIL_ADDRESSES'='<receiver mail address>' \
    -e 'NOTIFICATION_PASSWORD'='<GMail token password>' \
    -e 'HOUSE_ADDRESS'='<House Address>' \
    -e 'TZ'='Europe/Rome' \
    rcitton/outage_detector
    ```

    ### b. leveraging on SMTP notification
    ```
    docker run -d -t --name=outage_detector \
    -e 'NOTIFICATION_TYPE'='mail' \
    -e 'SENDER_MAIL_ADDRESS'='<sender mail address (no GMail address)>' \
    -e 'RECEIVER_MAIL_ADDRESSES'='<receiver mail address>' \
    -e 'SMTP_SERVER'='<SMTP server address>' \
    -e 'SMTP_SERVER_PORT'='<SMTP server port>' \
    -e 'NOTIFICATION_PASSWORD'='<GMail token password>' \
    -e 'HOUSE_ADDRESS'='<House Address>' \
    -e 'TZ'='Europe/Rome' \
    rcitton/outage_detector
    ```

    ### c. leveraging on iftt notification
    ```
    docker run -d -t --name=outage_detector \
    -e 'NOTIFICATION_TYPE'='ifttt' \
    -e 'IFTTT_NAME'='<iftt name>' \
    -e 'NOTIFICATION_PASSWORD'='<IFTT token password>' \
    -e 'HOUSE_ADDRESS'='<House Address>' \
    -e 'TZ'='Europe/Rome' \
    rcitton/outage_detector
    ```

    ### d. leveraging on 'Pushbullet' notification
    ```
    docker run -d -t --name=outage_detector \
    -e 'NOTIFICATION_TYPE'='pushbullet' \
    -e 'NOTIFICATION_PASSWORD'='<Pushbullet token password>' \
    -e 'HOUSE_ADDRESS'='<House Address>' \
    -e 'TZ'='Europe/Rome' \
    rcitton/outage_detector
    ```

## Environment Variables

Use OS or Docker environmet variables to configure the program run.

| Variable                | Default Value        | Informations                                                 |
|:------------------------|:---------------------|:-------------------------------------------------------------|
| NOTIFICATION_TYPE       |                      | Notification type: mail, ifttt, pushbullet                   |
| SENDER_MAIL_ADDRESS     |                      | Sender mail address                                          |
| RECEIVER_MAIL_ADDRESSES |                      | Receiver mail address                                        |
| SMTP_SERVER             |                      | SMTP Server address                                          |
| SMTP_SERVER_PORT        |                      | SMTP Server Port                                             |
| IFTTT_NAME              |                      | IFTTT Name                                                   |
| NOTIFICATION_PASSWORD   |                      | Notification token/password                                  |
| OUTAGE_CHECK            |         5            | Outage check interval  (min)                                 |
| HOUSE_ADDRESS           |                      | Description of the run location                              |
| TZ                      | Europe/Rome          | Time zone                                                    |


## How to run it outside container

Install the module in a virtual environment with pip:

```
pip3 install Outage-Detector
```

Alternatively, you can also install the module by cloning this git repo and running setup.py

```
git clone https://github.com/fabytm/Outage-Detector.git
python3 setup.py install
```

Afterwards, all you need to do is to run the outage_detector command line interface for the initialization process:

```
outage_detector --init
```

From here you can choose the way you want to be notified and will be prompted to enter your e-mail information, PushBullet API key or IFTTT API key.

Additionally, it will also ask you if you want to set up scheduling for this module. Choosing to do so is recommended for inexperienced users (this will create 2 cron jobs, one running at boot time and one every 5 minutes, to check in on internet status and record timestamp if either the internet connection drops or a power outage happens).

Update the module to the latest version in a virtual environment with pip:

```
pip3 install Outage-Detector --upgrade
```

## How to setup GMail

GMail two factor authentification is not supported. You need to define an App password.

Important: To create an app password, you need 2-Step Verification on your Google Account.

Create & use app passwords:

    Go to your Google Account.
    Select Security
    Under "Signing in to Google," select 2-Step Verification.
    At the bottom of the page, select App passwords.
    Enter a name that helps you remember where you’ll use the app password.
    Select Generate.
    To enter the app password, follow the instructions on your screen. The app password is the 16-character code that generates on your device.
    Select Done.

The generated token is your 'NOTIFICATION_PASSWORD'.


## How to setup IFTTT

Install the IFTTT app and either create an account or sign in to an existing account and create a new applet. 

Next, select the 'add' button beside the word 'If This' and choose the Webhooks service. Select 'Recieve a web request', choose an event name (i.e.' OutageDetector') — you will need to remember this for 'IFTTT_NAME'. Select 'Create trigger' button

Select the 'add' button beside the word 'Then That' and choose any action that you like. For example 'Notifications'.
Clear everything from the message text box and choose Value1 from the Insert Ingredients menu. Enter any necessary information and press 'Create action'.

Select 'Continue' an 'Finish'

Select the Webhooks icon in the top left of the screen and press the 'Documentation' button (in a web browser). This will give you a key which you will need for 'NOTIFICATION_PASSWORD'.


## How to setup PushBullet
See details at https://www.pushbullet.com/

## Test Notification setup
You may test your OutageDetector notification setup issuing the command:

```
docker container run -it outage_detector /usr/local/bin/python /usr/local/bin/outage_detector --run boot --notify <mail|iftt|pushbullet>
```