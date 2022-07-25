import {LightningElement, track} from 'lwc';
import getHelloWorld from '@salesforce/apex/HelloWorldController.getHelloWorld';

export default class HelloWorld extends LightningElement {

    @track greeting;

    connectedCallback() {
        getHelloWorld({ 'name' : 'Andrey' })
            .then(result => {
                this.greeting = result;
            })
            .catch(error => {
                console.error(error);
            })
    }

}