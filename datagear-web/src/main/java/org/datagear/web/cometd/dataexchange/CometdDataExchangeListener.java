/*
 * Copyright (c) 2018 datagear.org. All Rights Reserved.
 */

package org.datagear.web.cometd.dataexchange;

import org.cometd.bayeux.server.ServerChannel;
import org.datagear.dataexchange.DataExchangeException;
import org.datagear.dataexchange.DataExchangeListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 基于Cometd的{@linkplain DataExchangeListener}。
 * 
 * @author datagear@163.com
 *
 */
public abstract class CometdDataExchangeListener implements DataExchangeListener
{
	protected static final Logger LOGGER = LoggerFactory.getLogger(CometdDataExchangeListener.class);

	private DataExchangeCometdService dataExchangeCometdService;

	private ServerChannel dataExchangeServerChannel;

	private volatile long _startTime = System.currentTimeMillis();

	public CometdDataExchangeListener()
	{
		super();
	}

	public CometdDataExchangeListener(DataExchangeCometdService dataExchangeCometdService,
			ServerChannel dataExchangeServerChannel)
	{
		super();
		this.dataExchangeCometdService = dataExchangeCometdService;
		this.dataExchangeServerChannel = dataExchangeServerChannel;
	}

	public void setDataExchangeCometdService(DataExchangeCometdService dataExchangeCometdService)
	{
		this.dataExchangeCometdService = dataExchangeCometdService;
	}

	public ServerChannel getDataExchangeServerChannel()
	{
		return dataExchangeServerChannel;
	}

	public void setDataExchangeServerChannel(ServerChannel dataExchangeServerChannel)
	{
		this.dataExchangeServerChannel = dataExchangeServerChannel;
	}

	@Override
	public void onStart()
	{
		this._startTime = System.currentTimeMillis();
		sendMessage(buildStartMessage());
	}

	@Override
	public void onException(DataExchangeException e)
	{
		sendMessage(buildExceptionMessage(e));
	}

	@Override
	public void onSuccess()
	{
		sendMessage(buildSuccessMessage());
	}

	@Override
	public void onFinish()
	{
		long duration = System.currentTimeMillis() - this._startTime;
		sendMessage(buildFinishMessage(duration));
	}

	/**
	 * 发送消息。
	 * 
	 * @param dataExchangeMessage
	 */
	protected void sendMessage(DataExchangeMessage dataExchangeMessage)
	{
		try
		{
			this.dataExchangeCometdService.sendMessage(this.dataExchangeServerChannel, dataExchangeMessage);
		}
		catch (Throwable t)
		{
			LOGGER.error("send message error", dataExchangeMessage);
		}
	}

	/**
	 * 构建开始消息。
	 * 
	 * @return
	 */
	protected abstract DataExchangeMessage buildStartMessage();

	/**
	 * 构建异常消息。
	 * 
	 * @param e
	 * @return
	 */
	protected abstract DataExchangeMessage buildExceptionMessage(DataExchangeException e);

	/**
	 * 构建成功消息。
	 * 
	 * @return
	 */
	protected abstract DataExchangeMessage buildSuccessMessage();

	/**
	 * 构建完成消息。
	 * 
	 * @param duration
	 * @return
	 */
	protected abstract DataExchangeMessage buildFinishMessage(long duration);
}
