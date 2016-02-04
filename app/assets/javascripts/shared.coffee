window.focusParentDiv = (time = 0, offset = 0) ->
  script_tag = document.scripts[document.scripts.length - 1]
  script_parent = $(script_tag.parentNode)
  $('html, body').animate { scrollTop: script_parent.offset().top - offset }, time

window.bind_modal_events = (link) ->
  return unless link.is('[data-title]') && link.is('[data-message]')

  target = null
  if link.is('a') || link.is('input[type="button"]') || link.is('input[type="submit"]')
    copy = link.clone()
    copy.removeAttr('data-modal').removeAttr('data-title').removeAttr('data-message').removeAttr('data-remote').removeAttr('data-method').removeAttr('rel')
    link.after(copy)
    link.hide()
    target = copy
  else if link.is('[data-modal="message"]')
    target = link
  else
    return

  target.click (event) ->
    event.preventDefault()
    set_modal_properties(link, link.attr('data-modal'), link.attr('data-title'), link.attr('data-message'))
    $("#popup-modal").modal("show")

window.assign_modal_event = (identifier) ->
  $(identifier).find('*[data-modal]').each ->
    bind_modal_events($(this))

set_answer_param = (link, answer) ->
  if link.is('a')
    ref = link.attr('href')
    index = ref.lastIndexOf('?')
    joint = '?'
    if index >= 0
      joint = '&'
    link.attr('href', link.attr('href') + joint + 'answer=' + answer)
  else
    obj = link.parent().children('#answer')
    if obj.length > 0
      obj.attr('value', answer)
    else
      link.before($('<input>', { id: 'answer', type: 'hidden', value: answer, name: 'answer'}))

set_modal_properties = (link, type, title, message) ->
  modal = $('#popup-modal').children('div').children('div')
  modal.find('.modal-title').html(title)
  modal.find('.modal-body').html(message)
  footer = modal.children('.modal-footer')
  footer.html('')
  if type == 'confirm'
    var_yes = $('<button>', { type: "button", class: "btn btn-primary", 'data-dismiss': "modal" }).html('Yes')
    var_cancel = $('<button>', { type: "button", class: "btn btn-primary", 'data-dismiss': "modal" }).html('Cancel')
    footer.append(var_yes).append(var_cancel)
    var_yes.click ->
      link.get(0).click()
  else if type == 'question'
    var_yes = $('<button>', { type: "button", class: "btn btn-primary", 'data-dismiss': "modal" }).html('Yes')
    var_no = $('<button>', { type: "button", class: "btn btn-primary", 'data-dismiss': "modal" }).html('No')
    var_cancel = $('<button>', { type: "button", class: "btn btn-primary", 'data-dismiss': "modal" }).html('Cancel')
    footer.append(var_yes).append(var_no).append(var_cancel)
    var_yes.click ->
      set_answer_param(link, true)
      link.get(0).click()
    var_no.click ->
      set_answer_param(link, false)
      link.get(0).click()
  else if type == 'message'
    var_ok = $('<button>', { type: "button", class: "btn btn-primary", 'data-dismiss': "modal" }).html('Close')
    footer.append(var_ok)

#on load execution
$(document).ready () ->
  #applies modal messages on elements
  $('*[data-modal]').each ->
    bind_modal_events($(this))