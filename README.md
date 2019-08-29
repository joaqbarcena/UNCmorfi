# 🎟 UNCMorfi with reservations 🎟
## Main research explanation can be found on [UNCmorfiServer](https://github.com/joaqbarcena/UNCmorfiServer)

## Update 29/08
After some refactor, and test, i made it work inside the app, with some `chimi`, so i will focus on show the new features and options

- 🎟 Reservation : 
	- Swipe to left and click on **Reservation**,
	- If you haven't logged-in before it will ask you for captcha showed on an AlertView
		- Once you fill-it up go **Done** to send login and do the reservation
		- if it's login ok the session will be stored in the phone as `UserPref` (to refactor) known as `Session Trick`
	- If you previusly do the captcha login, then the app will re-use that session
	- If reservation goes ok, that's all ! you are gonna eat congrats !!!
	- Else maybe the session expires, the captcha was incorrect, there is no more reservations or you're out of time
- 😈 Beast Mode (iOS 11 or Higher):
	- Swipe to right (fully)
	- This exploits the reservation (after gettinga a valid session stored) *i.e.* you had to be logged-in (if not, then it will request anyway), this will run a `Timer` between 0.7 ~ 2 seconds sending a reservation request (local : 0.7, remote : 2)
- ⚙️ Options (Developer settings) : 
	- **Clean reservation sessions** : if you got a trouble, this removes reservation logins
	- **Switch Local/Remote mode**: Local stands for making the reservations calls, and logics within the app, remote to let the server do that job (while right now is inconvenient due to expensive timing explained on [UNCmorfiServer](https://github.com/joaqbarcena/UNCmorfiServer)) it will stays in case the server could be placed on a Argentinian/Cordoba Host and the timing surpass the local timing or if you want simply test-it

#### In development 
I'been trying to implement some background-issued reservations actions but the result are weird

I'been working in parallel with givemeturn repos, where they were for research purpose, into this were wrote a correct implementation (or almost xd)

These are the implementation of `Reservations` in `uncmorfi`, using the [forked backend](https://github.com/joaqbarcena/UNCmorfiServer) (maybe for now)

It hasn't like anything of testing, no one other than my self, so its possible than this catalogue as `negrada` :D

# LICENSE
This project is licensed under the terms of the MIT license. More details in the LICENSE file.
