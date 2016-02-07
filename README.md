# Birthdays-and-Reminders
A event based app that uses sync service.

The app alows you create an event, modify an event  or delete an existing event. All these changes are tracked in the 
core data (local dataStore) in the app. when the user performs/presses a refresh or sync. The app does the following for you:

1. It fetches new changes from the server

2. It determines if the incoming object is a new object or a existing object which could potentially have been modified. Incase of new object we just add it to coreData and for existing object we update our local object.

3. The it gets a list of all object that has been deleted by the user and sends a request to server to delete them. On success it clears those objects locally.

On every sync, the app resolves the delta between the server and the local data and keeps your data in sync. This allows a user access the account and data on multiple devices. 
