<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
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

<%@ include file="/export/init.jsp" %>

<liferay-staging:defineObjects />

<%
String cmd = ParamUtil.getString(request, Constants.CMD);

if (Validator.isNull(cmd)) {
	cmd = Constants.ADD;
}

if (liveGroup == null) {
	liveGroup = group;
	liveGroupId = groupId;
}

long exportImportConfigurationId = 0;

ExportImportConfiguration exportImportConfiguration = null;
Map<String, Serializable> exportImportConfigurationSettingsMap = Collections.emptyMap();

if (SessionMessages.contains(liferayPortletRequest, portletDisplay.getId() + "exportImportConfigurationId")) {
	exportImportConfigurationId = (Long)SessionMessages.get(liferayPortletRequest, portletDisplay.getId() + "exportImportConfigurationId");

	if (exportImportConfigurationId > 0) {
		exportImportConfiguration = ExportImportConfigurationLocalServiceUtil.getExportImportConfiguration(exportImportConfigurationId);
	}

	exportImportConfigurationSettingsMap = (Map<String, Serializable>)SessionMessages.get(liferayPortletRequest, portletDisplay.getId() + "settingsMap");
}
else {
	exportImportConfigurationId = ParamUtil.getLong(request, "exportImportConfigurationId");

	if (exportImportConfigurationId > 0) {
		exportImportConfiguration = ExportImportConfigurationLocalServiceUtil.getExportImportConfiguration(exportImportConfigurationId);

		exportImportConfigurationSettingsMap = exportImportConfiguration.getSettingsMap();
	}
}

if (MapUtil.isNotEmpty(exportImportConfigurationSettingsMap)) {
	privateLayout = GetterUtil.getBoolean(exportImportConfigurationSettingsMap.get("privateLayout"), privateLayout);
}

String rootNodeName = StringPool.BLANK;

if (privateLayout) {
	rootNodeName = LanguageUtil.get(request, "private-pages");
}
else {
	rootNodeName = LanguageUtil.get(request, "public-pages");
}

String treeId = "layoutsExportTree" + liveGroupId + privateLayout;

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("mvcRenderCommandName", "viewExportConfigurations");
portletURL.setParameter("groupId", String.valueOf(groupId));
portletURL.setParameter("liveGroupId", String.valueOf(liveGroupId));
portletURL.setParameter("privateLayout", String.valueOf(privateLayout));

portletDisplay.setShowBackIcon(true);
portletDisplay.setURLBack(portletURL.toString());

renderResponse.setTitle((exportImportConfiguration == null) ? LanguageUtil.get(request, "new-export-template") : exportImportConfiguration.getName());
%>

<div class="container-fluid-1280">
	<portlet:actionURL name="editExportConfiguration" var="updateExportConfigurationURL">
		<portlet:param name="mvcRenderCommandName" value="editExportConfiguration" />
	</portlet:actionURL>

	<aui:form action='<%= updateExportConfigurationURL + "&etag=0&strip=0" %>' cssClass="lfr-export-dialog" method="post" name="fm1">
		<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= cmd %>" />
		<aui:input name="redirect" type="hidden" value="<%= portletURL.toString() %>" />
		<aui:input name="exportImportConfigurationId" type="hidden" value="<%= exportImportConfigurationId %>" />
		<aui:input name="groupId" type="hidden" value="<%= String.valueOf(groupId) %>" />
		<aui:input name="liveGroupId" type="hidden" value="<%= String.valueOf(liveGroupId) %>" />
		<aui:input name="privateLayout" type="hidden" value="<%= String.valueOf(privateLayout) %>" />
		<aui:input name="rootNodeName" type="hidden" value="<%= rootNodeName %>" />
		<aui:input name="treeId" type="hidden" value="<%= treeId %>" />
		<aui:input name="<%= PortletDataHandlerKeys.PORTLET_ARCHIVED_SETUPS_ALL %>" type="hidden" value="<%= true %>" />
		<aui:input name="<%= PortletDataHandlerKeys.PORTLET_CONFIGURATION_ALL %>" type="hidden" value="<%= true %>" />
		<aui:input name="<%= PortletDataHandlerKeys.PORTLET_SETUP_ALL %>" type="hidden" value="<%= true %>" />
		<aui:input name="<%= PortletDataHandlerKeys.PORTLET_USER_PREFERENCES_ALL %>" type="hidden" value="<%= true %>" />

		<liferay-ui:error exception="<%= LARFileNameException.class %>" message="please-enter-a-file-with-a-valid-file-name" />

		<div class="export-dialog-tree">
			<aui:fieldset-group markupView="lexicon">
				<liferay-staging:configuration-header exportImportConfiguration="<%= exportImportConfiguration %>" />

				<c:if test="<%= !group.isLayoutPrototype() && !group.isCompany() %>">
					<liferay-staging:select-pages action="<%= Constants.EXPORT %>" exportImportConfigurationId="<%= exportImportConfigurationId %>" groupId="<%= liveGroupId %>" privateLayout="<%= privateLayout %>" treeId="<%= treeId %>" />
				</c:if>

				<liferay-staging:content cmd="<%= cmd %>" exportImportConfigurationId="<%= exportImportConfigurationId %>" showAllPortlets="true" type="<%= Constants.EXPORT %>" />

				<liferay-staging:deletions cmd="<%= cmd %>" exportImportConfigurationId="<%= exportImportConfigurationId %>" />

				<liferay-staging:permissions action="<%= Constants.EXPORT %>" descriptionCSSClass="permissions-description" exportImportConfigurationId="<%= exportImportConfigurationId %>" global="<%= group.isCompany() %>" labelCSSClass="permissions-label" />
			</aui:fieldset-group>
		</div>

		<aui:button-row>
			<aui:button cssClass="btn-lg" type="submit" value="save" />

			<aui:button cssClass="btn-lg" href="<%= portletURL.toString() %>" type="cancel" />
		</aui:button-row>
	</aui:form>
</div>

<aui:script use="liferay-export-import">
	new Liferay.ExportImport(
		{
			archivedSetupsNode: '#<%= PortletDataHandlerKeys.PORTLET_ARCHIVED_SETUPS_ALL %>',
			commentsNode: '#<%= PortletDataHandlerKeys.COMMENTS %>',
			deletionsNode: '#<%= PortletDataHandlerKeys.DELETIONS %>',
			exportLAR: true,
			form: document.<portlet:namespace />fm1,
			incompleteProcessMessageNode: '#<portlet:namespace />incompleteProcessMessage',
			locale: '<%= locale.toLanguageTag() %>',
			namespace: '<portlet:namespace />',
			pageTreeId: '<%= treeId %>',
			rangeAllNode: '#rangeAll',
			rangeDateRangeNode: '#rangeDateRange',
			rangeLastNode: '#rangeLast',
			ratingsNode: '#<%= PortletDataHandlerKeys.RATINGS %>',
			setupNode: '#<%= PortletDataHandlerKeys.PORTLET_SETUP_ALL %>',
			timeZone: '<%= timeZone.getID() %>',
			userPreferencesNode: '#<%= PortletDataHandlerKeys.PORTLET_USER_PREFERENCES_ALL %>'
		}
	);

	var form = A.one('#<portlet:namespace />fm1');

	form.on(
		'submit',
		function(event) {
			event.preventDefault();

			var A = AUI();

			var allContentSelected = A.one('#<portlet:namespace /><%= PortletDataHandlerKeys.PORTLET_DATA_ALL %>').val();

			if (allContentSelected === 'true') {
				var portletDataControlDefault = A.one('#<portlet:namespace /><%= PortletDataHandlerKeys.PORTLET_DATA_CONTROL_DEFAULT %>');

				portletDataControlDefault.val(true);
			}

			submitForm(form, form.attr('action'), false);
		}
	);
</aui:script>

<aui:script>
	Liferay.Util.toggleRadio('<portlet:namespace />chooseApplications', '<portlet:namespace />selectApplications', ['<portlet:namespace />showChangeGlobalConfiguration']);
	Liferay.Util.toggleRadio('<portlet:namespace />allApplications', '<portlet:namespace />showChangeGlobalConfiguration', ['<portlet:namespace />selectApplications']);

	Liferay.Util.toggleRadio('<portlet:namespace />rangeAll', '', ['<portlet:namespace />startEndDate', '<portlet:namespace />rangeLastInputs']);
	Liferay.Util.toggleRadio('<portlet:namespace />rangeDateRange', '<portlet:namespace />startEndDate', '<portlet:namespace />rangeLastInputs');
	Liferay.Util.toggleRadio('<portlet:namespace />rangeLast', '<portlet:namespace />rangeLastInputs', ['<portlet:namespace />startEndDate']);
</aui:script>