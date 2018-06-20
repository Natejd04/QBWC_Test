class Notifications
	constructor: ->
		@notifications = $("[data-behavior='notifications']")
		@setup() if @notifications.length > 0

	setup: ->
		$("[data-behavior='notifications-link']").on "click", @handleClick
		$.ajax(
			url: "/notifications.json"
			dataType: "JSON"
			method: "GET"
			success: @handleSuccess
		)

	handleClick: (e) =>
		$.ajax(
			url: "/notifications/mark_as_read"
			dataType: "JSON"
			method: "POST"
			success: ->
				$("[data-behavior='unread-count']").text(0)
			)

	handleSuccess: (data) =>
		items = $.map data, (notification) ->
			if notification.type is "CreditMemo"
				"<a href='#{notification.url}'><div><i class='fa fa-exclamation fa-fw'></i> #{notification.notifiable.type}<span class='pull-right text-muted small'>#{notification.time}</span></div></a><li class='divider'></li>"
			else if notification.type is "Order"
				"<a href='#{notification.url}'><div><i class='fa fa-dollar fa-fw'></i> #{notification.notifiable.type}<span class='pull-right text-muted small'>#{notification.time}</span></div></a><li class='divider'></li>"
			else if notification.type is "Customer"
				"<a href='#{notification.url}'><div><i class='fa fa-users fa-fw'></i> #{notification.notifiable.type}<span class='pull-right text-muted small'>#{notification.time}</span></div></a><li class='divider'></li>"


		$("[data-behavior='unread-count']").text(items.length)
		$("[data-behavior='notification-items']").html(items)



jQuery ->
	new Notifications
