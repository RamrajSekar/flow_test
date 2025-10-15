// // import { LightningElement, wire, track } from 'lwc';
// // import trackDeadlines from '@salesforce/apex/PolicyDeadlineTracker.trackDeadlines';

// // export default class PolicyDeadlines extends LightningElement {
// //     @track deadlines = [];
// //     @track error;

// //     userId = ''; // leave blank to use logged-in user

// //     @wire(trackDeadlines, { inputs: '$inputs' })
// //     wiredDeadlines({ error, data }) {
// //         if (data && data.length > 0) {
// //             // Apex returns a list with one output object: data[0].deadlines
// //             const rawDeadlines = data[0].deadlines || [];
// //             this.deadlines = rawDeadlines.map(d => ({
// //                 id: d.id,
// //                 name: d.name,
// //                 status: d.status,
// //                 expirationDate: d.expirationDate,
// //                 className: new Date(d.expirationDate) <= new Date() ? 'urgent' : 'slds-text-color_weak'
// //             }));

// //             this.error = undefined;
// //             console.log('Raw deadlines from Apex:', rawDeadlines);
// //             console.log('Processed deadlines:', this.deadlines);
// //         } else if (error) {
// //             this.deadlines = [];
// //             this.error = error.body ? error.body.message : 'Unknown error';
// //             console.error('Wire error:', error);
// //         } else {
// //             this.deadlines = [];
// //         }
// //     }

// //     get inputs() {
// //         // If userId is blank, pass empty array to use logged-in user
// //         return this.userId ? [{ userId: this.userId }] : [];
// //     }

// //     get hasDeadlines() {
// //         return this.deadlines.length > 0;
// //     }
// // }

// import { LightningElement, wire, track } from 'lwc';
// import trackDeadlines from '@salesforce/apex/PolicyDeadlineTracker.trackDeadlines';

// export default class PolicyDeadlines extends LightningElement {
//     @track deadlines = [];
//     @track error;
//     @track pageSize = 5;
//     @track pageNumber = 1;
//     @track sortField = '';
//     @track sortDirection = 'asc';
//     userId = '';

//     // Define columns for the datatable
//     columns = [
//         {
//             label: 'Policy Name',
//             fieldName: 'url',
//             type: 'url',
//             typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
//         },
//         { label: 'Expiration Date', fieldName: 'expirationDate', type: 'date',sortable: true },
//         { label: 'Status', fieldName: 'status', type: 'text' , sortable: true}
//     ];

//     @wire(trackDeadlines, { inputs: '$inputs' })
//     wiredDeadlines({ error, data }) {
//         if (data && data.length) {
//             this.deadlines = data[0].deadlines.map(d => ({
//                 id: d.id,
//                 name: d.name,
//                 status: d.status,
//                 expirationDate: d.expirationDate,
//                 url: '/' + d.id, // compute URL here
//                 className: new Date(d.expirationDate).setHours(0,0,0,0) <= new Date().setHours(0,0,0,0)
//                     ? 'urgent slds-text-color_error'
//                     : ''
//             }));
//             this.error = undefined;
//             console.log('Processed deadlines:', this.deadlines);
//         } else if (error) {
//             this.deadlines = [];
//             this.error = error.body ? error.body.message : JSON.stringify(error);
//             console.error('Wire error:', this.error);
//         } else {
//             this.deadlines = [];
//         }
//     }

//     get hasDeadlines() {
//         return this.deadlines.length > 0;
//     }

//     get inputs() {
//         // If userId is blank, pass empty array to use logged-in user
//         return this.userId ? [{ userId: this.userId }] : [];
//     }

//     get noDataAndNoError() {
//     return !this.hasDeadlines && !this.error;
//     }

//     get processedDeadlines() {
//         return this.deadlines.map(policy => {
//             const isUrgent = new Date(policy.expirationDate) <= this.todayPlusThree;
//             return {
//                 ...policy,
//                 rowClass: isUrgent ? 'urgent-row' : ''
//             };
//         });
//     }

//     get paginatedDeadlines() {
//         const start = (this.pageNumber - 1) * this.pageSize;
//         const end = start + this.pageSize;
//         return this.sortedDeadlines.slice(start, end);
//     }

//     get sortedDeadlines() {
//         if (!this.sortField) return this.deadlines;
//         return [...this.deadlines].sort((a, b) => {
//             let aVal = a[this.sortField];
//             let bVal = b[this.sortField];
//             if (this.sortField === 'expirationDate') {
//                 aVal = new Date(aVal);
//                 bVal = new Date(bVal);
//             }
//             return (aVal > bVal ? 1 : -1) * (this.sortDirection === 'asc' ? 1 : -1);
//         });
//     }

//     get isNextDisabled() {
//         return this.pageNumber * this.pageSize >= this.deadlines.length;
//     }
    
//     get isPrevDisabled() {
//         return this.pageNumber === 1;
//     }

//     handleNext() {
//         if (this.pageNumber * this.pageSize < this.deadlines.length) this.pageNumber++;
//     }

//     handlePrev() {
//         if (this.pageNumber > 1) this.pageNumber--;
//     }

//     handleSort(event) {
//         const { fieldName, sortDirection } = event.detail;
//         this.sortField = fieldName;
//         this.sortDirection = sortDirection;
//     }

//     get getRowClass() {
//         return row => row.rowClass || '';
//     }
// }

import { LightningElement, wire, track } from 'lwc';
import trackDeadlines from '@salesforce/apex/PolicyDeadlineTracker.trackDeadlines';
import { NavigationMixin } from 'lightning/navigation';
// @ts-nocheck

export default class PolicyDeadlines extends NavigationMixin(LightningElement) {
    @track deadlines = [];
    @track error;
    @track pageSize = 5;
    @track pageNumber = 1;
    @track sortField = '';
    @track sortDirection = 'asc';
    userId = '';

    actions = [
    { label: 'View', name: 'view' },
    { label: 'Renew', name: 'renew' },
    { label: 'Mark Complete', name: 'complete' }
    ];

    // DataTable columns
    columns = [
        {
            label: 'Policy Name',
            fieldName: 'url',
            type: 'url',
            typeAttributes: { label: { fieldName: 'name' }, target: '_blank' },
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        { 
            label: 'Expiration Date', 
            fieldName: 'expirationDate', 
            type: 'date', 
            sortable: true,
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        { 
            label: 'Status', 
            fieldName: 'status', 
            type: 'text', 
            sortable: true,
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        {
        type: 'action',
        typeAttributes: { rowActions: actions }
        }

    ];

    // Wire Apex
    @wire(trackDeadlines, { inputs: '$inputs' })
    wiredDeadlines({ error, data }) {
        if (data && data.length) {
            const today = new Date();
            today.setHours(0, 0, 0, 0);

            this.deadlines = data[0].deadlines.map(d => {
                const expiration = new Date(d.expirationDate);
                expiration.setHours(0, 0, 0, 0);

                const diffInDays = Math.floor((expiration - today) / (1000 * 60 * 60 * 24));
                const isUrgent = diffInDays <= 3;

                return {
                    id: d.id,
                    name: d.name,
                    status: d.status,
                    expirationDate: d.expirationDate,
                    url: '/' + d.id,
                    rowClass: isUrgent ? 'urgent-row' : ''
                };
            });
            console.log(this.deadlines)
            this.error = undefined;
            console.log('Processed deadlines:', this.deadlines);
        } else if (error) {
            this.deadlines = [];
            this.error = error.body ? error.body.message : JSON.stringify(error);
            console.error('Wire error:', this.error);
        } else {
            this.deadlines = [];
        }
    }

    get hasDeadlines() {
        return this.deadlines.length > 0;
    }

    get inputs() {
        return this.userId ? [{ userId: this.userId }] : [];
    }

    get noDataAndNoError() {
        return !this.hasDeadlines && !this.error;
    }

    get paginatedDeadlines() {
        const start = (this.pageNumber - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.sortedDeadlines.slice(start, end);
    }

    get sortedDeadlines() {
        if (!this.sortField) return this.deadlines;
        return [...this.deadlines].sort((a, b) => {
            let aVal = a[this.sortField];
            let bVal = b[this.sortField];
            if (this.sortField === 'expirationDate') {
                aVal = new Date(aVal);
                bVal = new Date(bVal);
            }
            return (aVal > bVal ? 1 : -1) * (this.sortDirection === 'asc' ? 1 : -1);
        });
    }

    get isNextDisabled() {
        return this.pageNumber * this.pageSize >= this.deadlines.length;
    }

    get isPrevDisabled() {
        return this.pageNumber === 1;
    }

    handleNext() {
        if (this.pageNumber * this.pageSize < this.deadlines.length) this.pageNumber++;
    }

    handlePrev() {
        if (this.pageNumber > 1) this.pageNumber--;
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortField = fieldName;
        this.sortDirection = sortDirection;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Policy__c',
                        actionName: 'view'
                    }
                });
                break;
            case 'renew':
                alert('Renew action for ' + row.Name + ' (to be implemented)');
                break;
            case 'complete':
                alert('Mark Complete action for ' + row.Name + ' (to be implemented)');
                break;
            default:
        }
    }
}