# Setup [Karabiner-Elements](https://karabiner-elements.pqrs.org/)

Open Karabiner-Elements application:

- Keyboard type: `ANSI`
- Allow in the background (`System Settings` > `General` > `Login Items & Extensions`)
    - Karabiner-Elements Non-Privileged Agents
    - Karabiner-Elements Privileged Daemons
- Input Monitoring (`System Settings` > `Privacy & Security` > `Input Monitoring`)
    - `karabiner-grabber`

Set up `Caps Lock` as a `Hyper Key` when pressed with other keys, and as `Caps Lock` itself when pressed alone.

Copy the following JSON configuration:

```json
{
    "description": "Caps Lock → Hyper Key (⌃⌥⇧⌘) (Caps Lock if alone)",
    "manipulators": [
        {
            "from": { "key_code": "caps_lock" },
            "to": [
                {
                    "key_code": "left_shift",
                    "modifiers": ["left_command", "left_control", "left_option"]
                }
            ],
            "to_if_alone": [{ "key_code": "caps_lock" }],
            "type": "basic"
        }
    ]
}
```

Open `Karabiner-Elements` > `Complex Modifications` > `Add your own rules` > Paste the JSON configuration above

After completing the above steps, go back to [README.md](../README.md) to continue the setup.
