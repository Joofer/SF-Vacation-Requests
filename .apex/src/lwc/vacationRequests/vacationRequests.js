import {LightningElement, track} from 'lwc';
import getVacationRequestList from '@salesforce/apex/VacationRequestsController.getVacationRequestList';

export default class VacationRequests extends LightningElement {

    @track vacationRequests;
    @track error;
    @track isModalAddRequestShown = false;

    handleLoad() {
        getVacationRequestList()
            .then(result => {
                this.vacationRequests = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    connectedCallback() {
        this.handleLoad();
    }

    openModalAddRequest() {
        this.isModalAddRequestShown = true;
    }

    closeModalAddRequest() {
        this.isModalAddRequestShown = false;
    }

    addRequest() {

    }

}