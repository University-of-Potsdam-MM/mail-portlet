<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
MailManager mailManager = MailManager.getInstance(request);

JSONObject defaultAccountsJSONObject = JSONFactoryUtil.createJSONObject(PortletPropsValues.DEFAULT_ACCOUNTS);

JSONArray accountsJSONArray = defaultAccountsJSONObject.getJSONArray("accounts");

String tabs1Names = "ZEIK Mail";

%>

<liferay-ui:tabs
	names="<%= tabs1Names %>"
	refresh="<%= false %>"
>

	<%
	//String userMail = PortalUtil.getUser(request).getEmailAddress();
	//String userName = userMail.split("@")[0];
	//String userPw = PortalUtil.getUserPassword(request);
	String userMail = user.getEmailAddress();
	String userName = user.getScreenName();
	
	
	JSONObject accountJSONObject = accountsJSONArray.getJSONObject(0);

	String titleLanguageKey = accountJSONObject.getString("titleLanguageKey");
	//String descriptionLanguageKey = accountJSONObject.getString("descriptionLanguageKey");
	String address = userMail;//accountJSONObject.getString("address");
	String protocol = "imap";
	boolean useLocalPartAsLogin = accountJSONObject.getBoolean("useLocalPartAsLogin");
	boolean hideSettings = true;//accountJSONObject.getBoolean("hideSettings");
	String incomingHostName = "imap.uni-potsdam.de";//accountJSONObject.getString("incomingHostName");
	int incomingPort = 993;//accountJSONObject.getInt("incomingPort");
	boolean incomingSecure = true;//accountJSONObject.getBoolean("incomingSecure");
	String outgoingHostName = "smtpout.uni-potsdam.de";//accountJSONObject.getString("outgoingHostName");
	int outgoingPort = 465;//accountJSONObject.getInt("outgoingPort");
	boolean outgoingSecure = true;//accountJSONObject.getBoolean("outgoingSecure");
	String folderPrefix = accountJSONObject.getString("folderPrefix");
	%>

		<liferay-ui:section>
			<aui:layout cssClass="mail-status" />

			<aui:form cssClass="account-form" name='<%= "dialogFm" + 1 %>' onSubmit="event.preventDefault();">
				<aui:input name="personalName" type="hidden" value="<%= user.getFullName() %>" />
				<aui:input name="protocol" type="hidden" value="<%= protocol %>" />
				<aui:input name="signature" type="hidden" />
				<aui:input name="useSignature" type="hidden" value="false" />
				<aui:input name="folderPrefix" type="hidden" value="<%= folderPrefix %>" />
				<aui:input name="defaultSender" type="hidden" value="false" />
				<aui:input name="useLocalPartAsLogin" type="hidden" value="<%= useLocalPartAsLogin %>" />

				<c:if test="<%= hideSettings %>">
					<aui:input name="incomingHostName" type="hidden" value="<%= incomingHostName %>" />
					<aui:input name="incomingPort" type="hidden" value="<%= incomingPort %>" />
					<aui:input name="incomingSecure" type="hidden" value="<%= incomingSecure %>" />
					<aui:input name="outgoingHostName" type="hidden" value="<%= outgoingHostName %>" />
					<aui:input name="outgoingPort" type="hidden" value="<%= outgoingPort %>" />
					<aui:input name="outgoingSecure" type="hidden" value="<%= outgoingSecure %>" />
				</c:if>

				<c:if test="<%= useLocalPartAsLogin %>">
					<aui:input name="login" type="hidden" />
				</c:if>

				<liferay-ui:message key="" />

				<aui:fieldset label="account-settings">
					<aui:input name="address" type="hidden" value="<%= address %>" />

					<c:if test="<%= !useLocalPartAsLogin %>">
						<aui:input name="login" type="hidden" value="<%= userName %>"/>
					</c:if>

					<aui:input name="password" type="password"/>

					<aui:input name="savePassword" type="checkbox" value="true" />
				</aui:fieldset>

				<c:if test="<%= !hideSettings %>">
					<aui:fieldset label="incoming-settings">
						<aui:input name="incomingHostName" />

						<aui:select name="incomingPort">

							<%
							for (int curIncomingPort : PortletPropsValues.INCOMING_PORTS) {
							%>

								<aui:option selected="<%= incomingPort == curIncomingPort %>" value="<%= curIncomingPort %>"><%= curIncomingPort %></aui:option>

							<%
							}
							%>

						</aui:select>

						<aui:input label="use-secure-incoming-connection" name="incomingSecure" type="checkbox" />
					</aui:fieldset>

					<aui:fieldset label="outgoing-settings">
						<aui:input label="outgoing-smtp-server" name="outgoingHostName" />

						<aui:select name="outgoingPort">

							<%
							for (int curOutgoingPort : PortletPropsValues.OUTGOING_PORTS) {
							%>

								<aui:option selected="<%= outgoingPort == curOutgoingPort %>" value="<%= curOutgoingPort %>"><%= curOutgoingPort %></aui:option>

							<%
							}
							%>

						</aui:select>

						<aui:input label="use-secure-outgoing-connection" name="outgoingSecure" type="checkbox" />
					</aui:fieldset>
				</c:if>

				<aui:button-row>
					<aui:button cssClass="add-account" type="submit" value="add-account" />
				</aui:button-row>
			</aui:form>
		</liferay-ui:section>

</liferay-ui:tabs>

<aui:script use="aui-io-deprecated">
	A.all('.mail-dialog form.account-form').on(
		'submit',
		function(event) {
			event.preventDefault();

			Liferay.Mail.setStatus('info', '<liferay-ui:message key="adding-account" />', true);

			var form = event.currentTarget;

			A.io.request(
				themeDisplay.getLayoutURL() + '/-/mail/update_account',
				{
					dataType: 'json',
					form: {
						id: form.getDOMNode()
					},
					method: 'POST',
					on: {
						failure: function(event, id, obj) {
							Liferay.Mail.setStatus('error', '<liferay-ui:message key="unable-to-connect-with-mail-server" />');
						},

						success: function(event, id, obj) {
							var responseData = this.get('responseData');

							Liferay.Mail.setStatus(responseData.status, responseData.message);

							if (responseData.status == 'success') {
								Liferay.Mail.loadAccounts(Liferay.Mail.accountId);
							}
						}
					}
				}
			);
		}
	);
</aui:script>