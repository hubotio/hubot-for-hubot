Helper = require('hubot-test-helper')
# helper loads all scripts passed a directory
helper = new Helper('../scripts')

co     = require('co')
expect = require('chai').expect

describe 'hello-world', ->

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  afterEach ->
    @room.destroy()

  context 'user says hi to hubot', ->
    beforeEach ->
      co =>
        yield @room.user.say 'alice', '@hubot ping'

    it 'should reply to user', ->
      expect(@room.messages).to.eql [
        ['alice', '@hubot ping']
        ['hubot', 'PONG']
      ]
