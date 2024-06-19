

I like to entertain the idea that this setup could be used by `mutt`, but it is unlikely that I will test it on anything but `neomutt`.

# Building your mail client system from scratch

## Workflows
Although IMAP4 and POP3 are currently the two most portable protocols for reading mail (not sending).
 - The traditional workflow of IMAP is that the server does all the bookkeeping and all your devices communicate via the internet to sync up with the server, ie. downloading all mail changes (deleted or recieved), thus you see the same thing on every device after syncing with the server.
 - The traditional workflow of POP is downloading all mail from the server which then deletes it off the server. You then manage all your mail locally. In the multiple device case, each time you poll the server, you only get the newest mail (because older mail is deleted) spreading your mail across multiple devices. Many modern (if not most) servers allow connections via POP to not delete mail retrieved, thus in the multiple device case you could have all the entire.


1. Read emails online. Your network speed makes logging in fetching mail (in particular mail with attachments) slow. Usually done with the IMAP protocol, but I imagine it is possible to do this with POP as well.
2. Read emails offline and sync those mail with online server. More steps
  * Read emails via IMAP
3. Use mail
4. Backup your mail. Just download everything and use one one of the above methods to read your mail

Neomutt by default comes with the ability to
1. Retrieve mail via IMAP(S) access things online, (replacing, web clients, ie. logging in to your browser for IMAP)
2. Retrieve mail via POP(S) access things offline and store files in a directory as. You can enable deletion or not. This is the full standard POP workflow.
3. Read local mail
4. Send via SMTP if you install `crypt-sasl-modules` (or something similar?) and set 'smtp_url' and 'smtp_pass' in your muttrc

Additionally you can store a header and mail cache. I'm not sure if you could fully implement IMAP by keeping the mail cache and running neomutt


# Protonmail and others
The protonbridge emulates an IMAP server on local computer. It sets up a port 

This means that 

# Comparison

## Retrieving mail
- offlineimap: an ongoing fork of it i

## Sending mail
- crypt-sasl

## Indexing
