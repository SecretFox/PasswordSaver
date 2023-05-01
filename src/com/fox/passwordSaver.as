import GUIFramework.SFClipLoader;
import com.GameInterface.AccountManagement;
import mx.utils.Delegate;

class com.fox.passwordSaver
{
	private var HookTimeout:Number;

	public static function main(swfRoot:MovieClip)
	{
		var mod:passwordSaver = new passwordSaver();
		swfRoot.onLoad = function() {mod.Load()};
	}

	public function passwordSaver(){
		Hook();
	}

	private function Load()
	{
		AccountManagement.GetInstance().SignalLoginStateChanged.Connect(SlotLoginStateChanged, this);
		SlotLoginStateChanged(AccountManagement.GetInstance().GetLoginState());
	}

	private function SlotLoginStateChanged(state:Number)
	{
		if ( state == _global.Enums.LoginState.e_LoginStateInPlay)
		{
			clearTimeout(HookTimeout);
			AccountManagement.GetInstance().SignalLoginStateChanged.Disconnect(SlotLoginStateChanged, this);
			delete _global.com.fox.passwordSaver;
			SFClipLoader.UnloadClip("passwordsaver\\passwordsaver");
		}
		else Hook();
	}

	private function Hook():Void
	{
		var login = _root.logincharacterselection.m_LoginWindow;
		if ( !login )
		{
			clearTimeout(HookTimeout);
			HookTimeout = setTimeout(Delegate.create(this, Hook), 5);
			return;
		}
		if ( login.hooked ) return;
		login.CheckInputFields = undefined; // prevent login button from disabling
		login.LoginToCharacterSelection = Delegate.create(this, LoginPressed); // Override login function
		login.m_LoginButton.disabled = false;
		login.m_LoginButton.m_ForwardArrow._alpha = 100;
		login.hooked = true;
	}

	private function LoginPressed()
	{
		var XMLFile = new XML();
		XMLFile.ignoreWhite = true;
		XMLFile.onLoad = Delegate.create(this, function()
		{
			if (arguments[0])
			{
				var login = _root.logincharacterselection.m_LoginWindow;
				var char:String = login.m_UsernameInput.text;
				var root:XMLNode = XMLFile.childNodes[0];
				for (var i in root.childNodes)
				{
					var charNode:XMLNode = root.childNodes[i];
					if (char.toLowerCase() == charNode.attributes.name.toLowerCase())
					{
						AccountManagement.GetInstance().LoginAccount(char, charNode.attributes.pass);
						break;
					}
				}
			}
		});
		XMLFile.load("passwordSaver/accountData.xml");
	}
}