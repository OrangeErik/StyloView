library dart_amqp;


export "src/client.dart";
export "src/enums.dart";
export "src/exceptions.dart";
export "src/authentication.dart";
export "src/protocol.dart" show MessageProperties;


import 'dart_amqp.dart' as mq;
import 'package:StyloView/functional/SELib.dart';
import 'package:uuid/uuid.dart';

mq.Client CreateClient(mq.ConnectionSettings connectionSetting)
{
	try{
		mq.Client client = mq.Client(settings:  connectionSetting);
		return client;
	}
	catch(e){
		print(e);
		print("Нет соединения с интернетом");
		return null;
	}
}

Future<mq.Channel> CreateChannelForClient(mq.Client client)async
{
	try{
		mq.Channel channel =await client.channel();
		return channel;
	}
	catch(e){
		print(e);
		print("Нет соединения с интернетом");
		return null;
	}
}

Future<mq.Exchange> BindExchangeForChannel(mq.Channel channel, String exchangeName, mq.ExchangeType exchangeType)async
{
	mq.Exchange exchange =await channel.exchange(exchangeName, exchangeType);
	return exchange;
}

Future<mq.Queue> CreateQueue(mq.Channel channel, String queueName)async
{
	mq.Queue queue =await channel.queue(queueName);
	return queue;
}

Future<void> BindExchangeAndQueueByRoutingKey(mq.Queue queue, mq.Exchange exchange, dynamic routingKey)async
{
	await queue.bind(exchange, routingKey);
}

class VarMQ{
/* Descr: Флаги, используемые в различных функциях обмена сообщениями.
	     Ради унификации все они вседены в общий enum.*/
	static const int mqofPassive    = 0x0001;  // queue exchange
	static const int mqofDurable    = 0x0002;  // queue exchange
	static const int mqofExclusive  = 0x0004;  // queue exchange consume
	static const int mqofAutoDelete = 0x0008;  // queue exchange
	static const int mqofNoLocal    = 0x0010;  // consume
	static const int mqofNoAck      = 0x0020;  // consume cancel
	static const int mqofInternal   = 0x0040;  // exchange
	static const int mqofMultiple   = 0x0080;  // ack
/*Descr: Типы зарезервированных параметров маршрутизации*/
	static const int rtrsrvPapyrusDbx         = 1; // Обмен пакетами синхронизации баз данных
	static const int rtrsrvPapyrusPosProtocol = 2; // Обмен между хостом и автономными кассовыми узлами Papyrus
	static const int rtrsrvStyloView          = 3; // Обмен с системой StyloView
	static const int rtrsrvRpc                = 4; // Короткие запросы
	static const int rtrsrvRpcListener        = (rtrsrvRpc | 0x8000); // Короткие запросы (только слушатель)
	static const int rtrsrvRpcReply           = 5; // Ответы на rtrsrvRpc

	static const Map<int, String> MqbReservedRoutePrefix = {
		rtrsrvPapyrusPosProtocol: "papyrusposprotocol" ,
		rtrsrvPapyrusDbx: "papyrusdbx" ,
		rtrsrvStyloView:  "papyrusstyloview" ,
		rtrsrvRpcReply:   "papyrusrpcreply" ,
		rtrsrvRpc:        "papyrusrpc" ,
	};
}

class Message {
	Message(){
		Props = mq.MessageProperties();
	}
	mq.MessageProperties Props;
	String Body;
}

class RoutingParamEntry {
	int RtRsrv;
	int QueueFlags;
	int ExchangeFlags;
	int RpcReplyQueueFlags;
	int RpcReplyExchangeFlags;
	mq.ExchangeType RpcReplyExchangeType;
	mq.ExchangeType ExchangeType; // exgtXXX1
	String QueueName;
	String ExchangeName;
	String RoutingKey;
	String CorrelationId;
	String RpcReplyQueueName;
	String RpcReplyExchangeName;
	String RpcReplyRoutingKey;

	RoutingParamEntry();
	int Z()
	{
		RtRsrv = null;
		QueueFlags = null;
		ExchangeFlags = null;
		RpcReplyQueueFlags = null;
		RpcReplyExchangeFlags = null;
		RpcReplyExchangeType = null;
		ExchangeType = null; // exgt
		QueueName = null;
		ExchangeName = null;
		RoutingKey = null;
		CorrelationId = null;
		RpcReplyQueueName = null;
		RpcReplyExchangeName = null;
		RpcReplyRoutingKey = null;
		return D.OK;
	}

	int SetupReserved(int rsrv, String domainName, String destGuid, int destId)
	{
		int    ok = D.OK;
		String symb;
		symb = VarMQ.MqbReservedRoutePrefix[rsrv & ~0x8000];
		if(symb == null){return D.FAIL;}
		RtRsrv = rsrv;
		switch(rsrv & ~0x8000) {
			case VarMQ.rtrsrvPapyrusDbx:
				{
					if(domainName.isNotEmpty){
						if(destId > 0){
							QueueName = symb+'.'+domainName+'.'+destId.toString();
							RoutingKey = domainName+'.'+destId.toString();
							ExchangeName = symb;
							QueueFlags = 0;
							ExchangeType = mq.ExchangeType.DIRECT;
							ExchangeFlags = 0;
						}
					}
				}
				break;
			case VarMQ.rtrsrvPapyrusPosProtocol:
				{
					if(domainName.isNotEmpty){
						if(destGuid != null && destGuid.isNotEmpty){
							QueueName = symb+'.'+domainName+'.'+destGuid.toLowerCase();
							RoutingKey = domainName+'.'+destGuid.toLowerCase();
							ExchangeName = symb;
							QueueFlags = 0;
							ExchangeType = mq.ExchangeType.DIRECT;
							ExchangeFlags = 0;
						}
					}
				}
				break;
			case VarMQ.rtrsrvStyloView:
				{
					if(domainName.isNotEmpty){
						if(destGuid != null && destGuid.isNotEmpty){
							QueueName = symb+'.'+domainName+'.'+destGuid.toLowerCase();
							RoutingKey = domainName+'.'+destGuid.toLowerCase();
							ExchangeName = symb;
							QueueFlags = 0;
							ExchangeType = mq.ExchangeType.DIRECT;
							ExchangeFlags = 0;
						}
					}
				}
				break;
			case VarMQ.rtrsrvRpc:
				{
					String temp_buf;
					if(domainName.isNotEmpty){
						QueueName = symb+'.'+domainName;
						if(destGuid.isNotEmpty)
							QueueName = QueueName+'.'+destGuid.toLowerCase();
						else if(destId > 0)
							QueueName = QueueName+'.'+destId.toString();
						RoutingKey = domainName;
						if(destGuid.isNotEmpty)
							RoutingKey = RoutingKey+'.'+destGuid.toLowerCase();
						else if(destId > 0)
							RoutingKey = RoutingKey+'.'+destId.toString();
						ExchangeName = symb;
						QueueFlags = 0;
						ExchangeType = mq.ExchangeType.DIRECT;
						ExchangeFlags = 0;
						if(rsrv & 0x8000 == 0) {
							String reply_guid = Uuid().v4();
							reply_guid = reply_guid.replaceAll("-", "");
							CorrelationId = reply_guid.toLowerCase();
							temp_buf = VarMQ.MqbReservedRoutePrefix[VarMQ.rtrsrvRpcReply];
							if(temp_buf == null){return D.FAIL;}
							RpcReplyQueueName = temp_buf+'.'+domainName+'.'+reply_guid.toLowerCase();
							RpcReplyQueueFlags = VarMQ.mqofAutoDelete;
							RpcReplyExchangeName = temp_buf;
							RpcReplyExchangeType = mq.ExchangeType.DIRECT;
							RpcReplyExchangeFlags = 0;
							RpcReplyRoutingKey = RpcReplyQueueName;
						}
					}
				}
				break;
			case VarMQ.rtrsrvRpcReply:
				{
					// @construction
				}
				break;
			default:
				ok = D.FAIL;
				break;
		}
		return ok;
	}
//	int SetupRpcReply(const PPMqbClient::Envelope & rSrcEnv);
}
