<#include "../../include/import_global.ftl">
<#include "../../include/html_doctype.ftl">
<#--
titleMessageKey 标题标签I18N关键字，不允许null
formAction 表单提交action，允许为null
readonly 是否只读操作，允许为null
-->
<#assign formAction=(formAction!'#')>
<#assign readonly=(readonly!false)>
<#assign isAdd=(formAction == 'saveAdd')>
<html>
<head>
<#include "../../include/html_head.ftl">
<title><#include "../../include/html_title_app_name.ftl">
	<@spring.message code='${titleMessageKey}' /> - <@spring.message code='dataSet.dataSetType.JsonFile' />
</title>
</head>
<body>
<div id="${pageId}" class="page-form page-form-dataSet page-form-dataSet-jsonFile">
	<form id="${pageId}-form" action="#" method="POST">
		<div class="form-head"></div>
		<div class="form-content">
			<#include "include/dataSet_form_html_name.ftl">
			<div class="workspace">
				<div class="form-item">
					<div class="form-item-label">
						<label><@spring.message code='dataSet.jsonFile' /></label>
					</div>
					<div class="form-item-value">
						<input type="hidden" id="${pageId}-originalFileName" value="${(dataSet.fileName)!''?html}" />
						<input type="hidden" name="fileName" value="${(dataSet.fileName)!''?html}" />
						<input type="text" name="displayName" value="${(dataSet.displayName)!''?html}" class="file-display-name ui-widget ui-widget-content" readonly="readonly" />
						<#if !readonly>
						<div class="fileinput-wrapper">
							<div class="ui-widget ui-corner-all ui-button fileinput-button"><@spring.message code='upload' /><input type="file"></div>
							<div class="upload-file-info"></div>
						</div>
						</#if>
					</div>
				</div>
				<div class="form-item form-item-encoding">
					<div class="form-item-label">
						<label><@spring.message code='dataSet.jsonFileEncoding' /></label>
					</div>
					<div class="form-item-value">
						<select name="encoding">
							<#list availableCharsetNames as item>
							<option value="${item}" <#if item == dataSet.encoding>selected="selected"</#if>>${item}</option>
							</#list>
						</select>
					</div>
				</div>
				<#include "include/dataSet_form_html_wow.ftl" >
			</div>
		</div>
		<div class="form-foot" style="text-align:center;">
			<#if !readonly>
			<input type="submit" value="<@spring.message code='save' />" class="recommended" />
			&nbsp;&nbsp;
			<input type="reset" value="<@spring.message code='reset' />" />
			<#else>
			<div class="form-foot-placeholder">&nbsp;</div>
			</#if>
		</div>
	</form>
	<#include "include/dataSet_form_html_preview_pvp.ftl" >
</div>
<#include "../../include/page_js_obj.ftl" >
<#include "../../include/page_obj_form.ftl">
<#include "include/dataSet_form_js.ftl">
<script type="text/javascript">
(function(po)
{
	po.dataSetProperties = <@writeJson var=dataSetProperties />;
	po.dataSetParams = <@writeJson var=dataSetParams />;
	
	$.initButtons(po.element());
	po.element("select[name='encoding']").selectmenu({ appendTo : po.element(), classes : { "ui-selectmenu-menu" : "encoding-selectmenu-menu" } });
	po.initWorkspaceHeight();
	po.initWorkspaceTabs();
	po.initDataSetPropertiesTable(po.dataSetProperties);
	po.initDataSetParamsTable(po.dataSetParams);
	po.initPreviewParamValuePanel();
	
	po.updatePreviewOptionsData = function()
	{
		var dataSet = po.previewOptions.data.dataSet;
		
		dataSet.fileName = po.element("input[name='fileName']").val();
		dataSet.encoding = po.element("select[name='encoding']").val();
		
		po.previewOptions.data.originalFileName = po.element("#${pageId}-originalFileName").val();
	};
	
	<#if formAction == 'saveEditForJsonFile'>
	//初始化预览数据，为po.isPreviewValueModified判断逻辑提供支持
	po.updatePreviewOptionsData();
	//编辑操作默认为预览成功
	po.previewSuccess(true);
	</#if>
	
	po.isPreviewValueModified = function()
	{
		var fileName = po.element("input[name='fileName']").val();
		var encoding = po.element("select[name='encoding']").val();
		
		var pd = po.previewOptions.data.dataSet;
		
		return (pd.fileName != fileName) || (pd.encoding != encoding);
	};
	
	po.previewOptions.url = po.url("previewJsonFile");
	po.previewOptions.beforePreview = function()
	{
		po.updatePreviewOptionsData();
		
		if(!this.data.dataSet.fileName)
			return false;
	};
	po.previewOptions.beforeRefresh = function()
	{
		if(!this.data.dataSet.fileName)
			return false;
	};
	
	po.initPreviewOperations();
	
	po.fileUploadInfo = function(){ return this.element(".upload-file-info"); };
	
	po.element(".fileinput-button").fileupload(
	{
		url : po.url("uploadFile"),
		paramName : "file",
		success : function(uploadResult, textStatus, jqXHR)
		{
			$.fileuploadsuccessHandlerForUploadInfo(po.fileUploadInfo(), false);
			po.element("input[name='fileName']").val(uploadResult.fileName);
			po.element("input[name='displayName']").val(uploadResult.displayName);
		}
	})
	.bind('fileuploadadd', function (e, data)
	{
		po.element("input[name='displayName']").val("");
		$.fileuploadaddHandlerForUploadInfo(e, data, po.fileUploadInfo());
	})
	.bind('fileuploadprogressall', function (e, data)
	{
		$.fileuploadprogressallHandlerForUploadInfo(e, data, po.fileUploadInfo());
	});
	
	$.validator.addMethod("dataSetJsonFilePreviewRequired", function(value, element)
	{
		return !po.isPreviewValueModified() && po.previewSuccess();
	});
	
	po.form().validate(
	{
		ignore : "",
		rules :
		{
			"name" : "required",
			"displayName" : {"required": true, "dataSetJsonFilePreviewRequired": true, "dataSetPropertiesRequired": true}
		},
		messages :
		{
			"name" : "<@spring.message code='validation.required' />",
			"displayName" :
			{
				"required": "<@spring.message code='validation.required' />",
				"dataSetJsonFilePreviewRequired": "<@spring.message code='dataSet.validation.previewRequired' />",
				"dataSetPropertiesRequired": "<@spring.message code='dataSet.validation.propertiesRequired' />"
			}
		},
		submitHandler : function(form)
		{
			var formData = $.formToJson(form);
			formData["properties"] = po.getFormDataSetProperties();
			formData["params"] = po.getFormDataSetParams();
			
			var originalFileName = po.element("#${pageId}-originalFileName").val();
			
			$.postJson("${contextPath}/analysis/dataSet/${formAction}?originalFileName="+originalFileName, formData,
			function(response)
			{
				po.pageParamCallAfterSave(true, response.data);
			});
		},
		errorPlacement : function(error, element)
		{
			error.appendTo(element.closest(".form-item-value"));
		}
	});
})
(${pageId});
</script>
</body>
</html>