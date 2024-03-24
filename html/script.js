new Vue({
    el: '#app',
    data: {
        garageVisible: false,
        swapVisible: false,
        transferVisible: false,
        garageImage: 'img/default.png',
        currentGarage: {},
        vehicles: [],
        currentVehicle: null,
        garages: [],
        helptext: '',
        locales: [],
    },
    created() {
        window.addEventListener('message', (event) => {
            let data = event.data;
            if (data.action == 'open') {
                this.garageVisible = true;
                this.vehicles = data.vehicles;
                this.garages = data.garages;
                this.locales = data.locale;
                $('.helptext').css('display', 'none');
                this.currentGarage = this.garages[data.garage];
                let img = new Image();
                img.onload = () => {
                    this.garageImage = `img/${data.garage}.png`;
                };
                img.onerror = () => {
                    console.error('Image not found or failed to load. Using default image.');
                    this.garageImage = 'img/default.png'; // Use default image
                };
                img.src = `img/${data.garage}.png`;
            } else if (data.action == 'helptext') {
                if (data.show) {
                    this.helptext = data.text;
                    $('.helptext').css('display', 'flex');
                } else {
                    $('.helptext').css('display', 'none');
                }
            }
        });
    },
    methods: {
        driveVehicle(vehicle) {
            this.garageVisible = false;
            $.post('https://ss-garage/driveVehicle', JSON.stringify({
                vehicle: vehicle
            }));
        },
        payForVehicle(vehicle) {
            this.garageVisible = false;
            $.post('https://ss-garage/payForImpound', JSON.stringify({
                vehicle: vehicle
            }));
        },
        swapGarage(vehicle) {
            this.currentVehicle = vehicle;
            this.garageVisible = false;
            this.swapVisible = true;
        },
        transferVehicle(vehicle) {
            this.garageVisible = false;
            this.currentVehicle = vehicle;
            this.transferVisible = true;
        },
        confirmTransfer() {
            let id = $("#transfervehicle").val();
            let price = $("#transferprice").val();

            $.post('https://ss-garage/transferVehicle', JSON.stringify({
                vehicle: this.currentVehicle,
                id: id,
                price: price
            }));

            this.close();
        },
        confirmSwap() {
            let garage = $("#garageSelect").val();

            $.post('https://ss-garage/swapGarage', JSON.stringify({
                vehicle: this.currentVehicle,
                garage: garage
            }));

            this.close();
        },
        close() {
            $('.helptext').css('display', 'flex');
            this.garageVisible = false;
            this.swapVisible = false;
            this.transferVisible = false;
            this.garages = [];
            this.vehicles = [];
            this.currentVehicle = null;
            $('#garageSelect').empty();
            $.post('https://ss-garage/close', JSON.stringify({}));

        },
        onKeyUp(data) {
            if (data.which == 27) {
                this.close();
            }
        }
    },
    mounted() {
        document.addEventListener('keyup', this.onKeyUp);
    },
    destroyed() {
        document.removeEventListener('keyup', this.onKeyUp);
    }
});
