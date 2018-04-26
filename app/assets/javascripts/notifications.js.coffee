class Notifications
	constructor: ->
	@notifications = $("[data-behavior='notifications']")
	@setup() if @notifications.length > 0

	setup: ->
		console.log(@notifications)


jQuery ->
	new Notifications