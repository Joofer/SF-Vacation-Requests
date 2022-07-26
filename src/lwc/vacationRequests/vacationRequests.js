import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UsrId from '@salesforce/user/Id';
import UsrManagerId from '@salesforce/schema/User.ManagerId';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// VacationRequestsController imports
import getVacationRequestList from '@salesforce/apex/VacationRequestsController.getVacationRequestList';
import getFilteredVacationRequestList from '@salesforce/apex/VacationRequestsController.getFilteredVacationRequestList';
import submitVacationRequest from '@salesforce/apex/VacationRequestsController.submitVacationRequest';
import approveVacationRequest from '@salesforce/apex/VacationRequestsController.approveVacationRequest';
import removeVacationRequest from '@salesforce/apex/VacationRequestsController.removeVacationRequest';

// Schema imports
import REQUEST_OBJECT from '@salesforce/schema/Vacation_Request__c';
import REQUEST_REQUESTTYPE_FIELD from '@salesforce/schema/Vacation_Request__c.RequestType__c';
import REQUEST_STARTDATE_FIELD from '@salesforce/schema/Vacation_Request__c.StartDate__c';
import REQUEST_ENDDATE_FIELD from '@salesforce/schema/Vacation_Request__c.EndDate__c';
import REQUEST_WORKINGDAYS_FIELD from '@salesforce/schema/Vacation_Request__c.WorkingDays__c';
import REQUEST_MANAGER_FIELD from '@salesforce/schema/Vacation_Request__c.Manager__c';

export default class VacationRequests extends LightningElement {

    @track vacationRequests;
    @track error;
    @track isModalAddRequestShown = false;
    @track isSucceed = false;

    @track managerId;

    @wire(getRecord, {recordId: UsrId, fields: [UsrManagerId]})
    wireUser({error,data}) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.ManagerId.value != null) {
                this.managerId = data.fields.ManagerId.value;
            }
        }
    }

    objectApiName = REQUEST_OBJECT;
    typeField = REQUEST_REQUESTTYPE_FIELD;
    startDateField = REQUEST_STARTDATE_FIELD;
    endDateField = REQUEST_ENDDATE_FIELD;
    workingDaysField = REQUEST_WORKINGDAYS_FIELD;
    managerField = REQUEST_MANAGER_FIELD;

    handleLoad() {
        getVacationRequestList()
            .then(result => {
                this.vacationRequests = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSuccess(event) {
        this.showSuccessMessage("Success", "Vacation request was successfully created!");
        this.isSucceed = true;
    }

    handleError(event) {
        this.showErrorMessage("Error", "Manager is not specified for current user.");
    }

    showSuccessMessage(title, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }

    showErrorMessage(title, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(toastEvent);
    }

    connectedCallback() {
        this.handleLoad();
    }

    // Request creation modal

    openModalAddRequest() {
        this.isSucceed = false;
        this.isModalAddRequestShown = true;
    }

    closeModalAddRequest() {
        this.isModalAddRequestShown = false;
    }

    // Request actions

    submitRequest(event) {
        let selectedRequestId = event.currentTarget.dataset.id;
        submitVacationRequest({ requestId: selectedRequestId })
            .then((result) => {
                if (result == true)
                    this.showSuccessMessage("Success", "Vacation request #" + selectedRequestId + " was submitted.");
                else
                    this.showErrorMessage("Error", "Something went wrong when submitting request #" + selectedRequestId + ".");
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when submitting request #" + selectedRequestId + " (" + error.message + ").");
                this.error = error;
            });
    }

    approveRequest(event) {
        let selectedRequestId = event.currentTarget.dataset.id;
        approveVacationRequest({ requestId: selectedRequestId })
            .then((result) => {
                if (result == true)
                    this.showSuccessMessage("Success", "Vacation request #" + selectedRequestId + " was approved.");
                else
                    this.showErrorMessage("Error", "Something went wrong when approving request #" + selectedRequestId + ".");
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when approving request #" + selectedRequestId + " (" + error.message + ").");
                this.error = error;
            });
    }

    removeRequest(event) {
        let selectedRequestId = event.currentTarget.dataset.id;
        removeVacationRequest({ requestId: selectedRequestId })
            .then((result) => {
                if (result == true)
                    this.showSuccessMessage("Success", "Vacation request #" + selectedRequestId + " was removed.");
                else
                    this.showErrorMessage("Error", "Something went wrong when removing request #" + selectedRequestId + ".");
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when removing request #" + selectedRequestId + " (" + error.message + ").");
                this.error = error;
            });
    }

}