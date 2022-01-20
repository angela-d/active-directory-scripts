# Find Users Who Have Never Changed their Password
## in Active Directory
Useful in scenarios where you require the user to change the password after first logon.

Setting this script as a task to email you can keep you updated on who has not yet changed their password for the first time.

- If your users have a **pwdLastSet** value (visible via AD's Attribute Editor), this script will ignore them

### Manually Assessing this Script's Usefulness
- Check the *pwdLastSet* value by going to:
- Active Directory Users & Computers
- View > Advanced Features
- Go to an OU of a user you want to check
- Right-click a user object > Properties
- Select the **Attribute Editor** tab

Note that the Attribute Editor tab may not show if you searched a user.  Navigate the forest and go directly to the user's OU.

If you're not sure where the OU is, click the **Object** tab, once in Properties.
