# Description
AutoHotKey bot to automate the skill training grind in Mabinogi. These bots can operate multiple compatible loops of skills (based on skill cooldowns) and is a very effective template for any player interested in automating the boring parts of this game. Watch for additional features, such as image search, in the future. This will enable auto-ranking of skills, automation of additional skills, and potentially automated map traversal. 

## How to use
- Install AutoHotKey from [here](https://www.autohotkey.com)
- Right click the `.ahk file` and select `compile` to turn the script into a `exe` (helps prevent anti-cheat from seeing AHK running)
- Run compiled executable as an administrator (required for Mabinogi to detect input)

### Startup config
When starting this bot, you will be prompted for your mana pool and the amount of mana the magic skill you are using for burn. This is used to calculate how many times the loop should cast the spell in order to bring you below 10% MP.
![](./docs/images/startup.gif)

### Inspiration loop
This bot will automatically loop through magic to burn off your MP and cast Inspiration.
![](./docs/images/inspiration.gif)

### Snapcast loop
This bot will automatically cast Snapcast and use a magic skill. It will attempt to target a nearby mob and use the skill before cancelling
![](./docs/images/snapcast.gif)

### Shield loop
This bot will automatically loop through `Ice Shield`, `Lightning Shield`, and `Fire Shield`. When this is enabled you will do one loop of all three shields, then check for `Inspiration` or `Snapcast` (if enabled) before resuming. This will allow you to run all 3 loops together.

- Image unavailabe. Use your imagination, I didn't bother recording this one.

#### Coming soon
- GUI where you can toggle which skill(s) to train
- GUI where you can input your custom hotkeys
  - Potentially update hotkeys for Mabinogi and relaunch client?
- GUI where you can select the magic you want to use and its rank
- Image search to automatically rank skills
- Image search to set walking paths for commerce
- Image search for static objects for gathering related life skills
- Potential Python wrapper to call `ahk` scripts with more complex functions
  - Orchestration of virtual machines
  - [ML driven image searching](https://github.com/Vijayabhaskar96/CSAimBot) using a retrained FPS aimbot (As in, teach Mabinogi how to play itself..)


### This bot is made with various specific needs. It is not generic and you can not just run it as is. You will need to modify your hotkeys or write new functions. I will work on creating more generic functions for use in the future if I see the need. I am nearly done with all of my skills