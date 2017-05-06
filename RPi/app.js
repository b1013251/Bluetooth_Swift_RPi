var bleno = require('bleno');

var name = 'My Raspberry';
var serviceUuids = ['ec00'];

var BlenoPrimaryService = bleno.PrimaryService;
class EchoCharacteristic extends bleno.Characteristic {
		constructor() {
				super({
						uuid: 'ec0e',
						properties: ['read', 'write', 'notify'],
						value: null
				});
				this._updateValueCallback = null;
		}

		onReadRequest(offset, callback) {
				console.log("onReadRequest");
				var data = new Buffer("!!ReadData!!")
				callback(this.RESULT_SUCCESS, data);
		}

		onWriteRequest(data, offset, withoutResponse, callback) {
				console.log("onWriteRequest");
				console.log(`data: ${data.toString()}`);

				if(this._updateValueCallback) {
					console.log('notyfying');
					this._updateValueCallback("WriteRespnoce");
				}
				callback(this.RESULT_SUCCESS);
		}

		onSubscribe(maxValueSize, updateValueCallback) {
				console.log("onSubscribe");
				this.subscribed = true
				this._updateValueCallback = updateValueCallback;
				this.timer = setInterval(function() {
						updateValueCallback(new Buffer("こんにちは！！！"))	
						console.log("こんにちは！！！！");
				}, 1000);
		}

		onUnsubscribe() {
				console.log("onUnsubscribe");
				clearInterval(this.timer);
				this._updateValueCallback = null;
		}
}

bleno.on('stateChange', function(state) {
		console.log('stateChange: ', state);
		if(state === 'poweredOn') {
				// 起動されたら、Advertisingに遷移する
				bleno.startAdvertising(name, serviceUuids, function(error) {
						if(error)	console.error(error);
				});
		} else {
				bleno.stopAdvertising();
		}
});

bleno.on('advertisingStart', function(error) {
		console.log('start advertising...' + (error ? 'error!' + error : 'success'));
		if (!error) {
				bleno.setServices([
								new BlenoPrimaryService({
										uuid: 'ec00',
										characteristics: [
												new EchoCharacteristic()
										]
								})
				]);
		} else {
				console.error(error);
		}
});
