# Project Name
By Nat Hem and Grace Desrochers
## Goal
For our project wanted to make a game that would inspire players to stray away from their daily commute and explore the parts of the T they may have never seen before! To do this, we came up with an auto-battler idle game where the player has to go to MBTA stations in real life in order to level up their party of trains in order to fight the T's greatest enemy: unexpected fires.
## How in Works
1. Every 30 seconds, the game fetches the user's current longitude and latitude
2. These are passed into our relay server which queries the MBTA API for any stations withing 0.1 miles.
3. As long as the user has not already collected that station in the past hour, any trains which stop at that station gain some XP, with a 4x bonus for first-time station discovery in order to promote taking unfamiliar lines
4. the first time each train gains XP, it is added to your party; you'll have to visit each of the four lines to fill your party!
5. Depending on their total XP and level, trains do a certain amount of damage at a certain rate of fire against the big evil fire elemental
6. But be careful! When the enemy is defeated, it comes back even stronger than before. You'll have to visit as many stations as you can to advance further and earn bragging rights amongst all your friends
## Challenges
- Any code stored locally in a Godot game can be easily decompiled and exposed, which made securing our API key a serious issue. We ended up writing a relay server which obscures our API key by acting as a middleman, taking the request parameters and contacts the MBTA API itself before returning the response back to the Godot client, which we hosted on a Raspberry Pi that Grace had sitting around. You can even make requests to https://mbta.gracie.foo yourself with the same args as you would the normal MBTA API server to try it yourself! The server-side code can be found at https://github.com/gracedes/mbta-api-relay
- Godot also has no native location data support, so we had to write a lot of the location and async API calls handling ourselves.
- Since we obviously could not visit every MBTA station within the competition time for testing, we had to write a versatile suite of debug tools for testing and demo purposes.
- No save file manager out there worked with our style of continuous idle gameplay, so we also wrote our own JSON save system which saves the most important data - like a train's total XP - and can then formulaically reconstruct other stats like its level, damage, and rate of fire from just that one integer value in order to minimize the amount of space save files would take on a player's device.
### Assets
All assets, including our beautiful 3D modeled trains, were made by hand by Nat.
### Tools Used
- Godot
- Blender
- MBTA API
- Figma
- Cloudflare Tunnel
- Node.js
#### Sound Credits
[PlasticImpactB5.wav](https://freesound.org/s/525105/) by jomse (Creative Commons 0)  
[Click_1.wav](https://freesound.org/s/478197/) by JonnyRuss01 (Creative Commons 0)  
[Page Turn 1.mp3](https://freesound.org/s/241322/) by RokkuNeo (Attribution 3.0)  
[Stone dragged on concrete floor (2)](https://freesound.org/s/205142/) by Pusteblumi (Attribution NonCommercial 4.0)  
