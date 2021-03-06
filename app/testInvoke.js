// NOTE Invoke action cannot be performed on peer without chaincode installed(no matter whether chaincode has been instantiated on this peer): Error: cannot retrieve package for chaincode adminChaincode/v0, error open /var/hyperledger/production/chaincodes/adminChaincode.v0: no such file or directory

const invoke = require('./invoke-chaincode').invokeChaincode
const helper = require('./helper')

const logger = require('./util/logger').new('testInvoke')
const invoke_fcn = ''
const invoke_args = []

const chaincodeName = 'adminChaincode'
const peerIndexes = [0]
const orgName = 'PM'
const channelName = 'delphiChannel'

const peers = helper.newPeers(peerIndexes, orgName)
const client = helper.getClient()
helper.getOrgAdmin(orgName, client).then(() => {
	const channel = helper.prepareChannel(channelName, client, true)
	return invoke(channel, peers, chaincodeName, invoke_fcn, invoke_args, client)
}).then(require('./invoke-chaincode').reducer).then(_ => logger.info(_))
const _testInvokeOnNewPeer = () => {
	const orgName = 'AM'
	const { peer_hostName_full, tls_cacerts } = helper.gen_tls_cacerts(orgName, 0)
	const peerPort = 7071
	const eventHubPort = 7073
	const AMPeer = helper.newPeer({ peerPort, peer_hostName_full, tls_cacerts })
	const peers = [AMPeer]//helper.newPeers(peerIndexes, orgName)
	AMPeer.peerConfig = {
		eventHubPort
	}
	helper.getOrgAdmin(orgName).then(() => {

		const channel = helper.prepareChannel(channelName)
		return invoke(channel, peers, chaincodeName, invoke_fcn, invoke_args, client)

	})
}

