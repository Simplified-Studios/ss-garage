let currentVehicle = null;

window.addEventListener('message', function(event) {
    if (event.data.type == 'open') {
        $('.garage-container').css('display', 'block')
        $('.vehicle-container').html('');
        currentVehicle = null;
        var vehicles = event.data.vehicles;
        var garages = event.data.garages;

        var garageImage = $('#garageimage');
        var garageImageURL = `img/${event.data.garageindex}.png`;
        garageImage.attr('src', garageImageURL);
        garageImage.on('error', function() {
            garageImage.attr('src', 'img/default.png');
            garageImage.off('error');
        });

        $('#garagelabel').text(event.data.garages[event.data.garageindex].label);

        vehicles.forEach(function(vehicle, index) {
            var vehicleHtml = `
            <details class="group rounded-lg open:bg-slate-800">
            <summary class="flex cursor-pointer list-none items-center justify-between bg-slate-800 rounded-lg px-3 py-2 text-[15px] font-medium text-white hover:bg-slate-800">
                <summary class="flex">
                    <a class="mr-2 rounded-md bg-green-300 text-xs font-medium tracking-wide px-[5px] py-[2px] text-green-800">${vehicle.plate}</a>
                    <carname class="text-ellipsis line-clamp-1">${vehicle.fullname}</carname>
                </summary>
                <div class="text-secondary-500">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="block h-5 w-5 group-open:hidden">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="hidden h-5 w-5 group-open:block">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                </div>
            </summary>
            <div class="px-6 pb-4 text-xs text-white">
                ${vehicle.state === 0 ?
                    '<br><a class="ml-2 rounded-md bg-rose-400 text-xs font-medium tracking-wide px-[5px] py-[2px] text-stone-800">Out</a>' :
                    vehicle.state === 1 ?
                    `<br><a class="rounded-md bg-slate-600 text-xs font-medium tracking-wide px-[5px] py-[2px] text-white">${event.data.garages[event.data.garageindex].label}</a>` :
                    vehicle.state === 2 ?
                    '<br><a class="ml-2 rounded-md bg-rose-400 text-xs font-medium tracking-wide px-[5px] py-[2px] text-stone-800">Impounded</a>' :
                    ''
                }
                <p class="mt-5 text-[15px] font-bold">Vehicle Status</p>
                <div class="space-y-1">
                    <dl class="flex items-center justify-between">
                    <dt class="mt-1 text-sm font-medium text-secondary-700">Fuel</dt>
                    <dd class="text-sm text-secondary-500">${vehicle.fuel}%</dd>
                    </dl>
                    <div class="relative flex h-2 w-full overflow-hidden rounded-full bg-slate-700">
                    <div role="progressbar" aria-valuenow="${vehicle.fuel}" aria-valuemin="0" aria-valuemax="100" style="width: ${vehicle.fuel}%" class="flex h-full items-center justify-center bg-orange-300 text-white"></div>
                    </div>
                    <dl class="flex items-center justify-between">
                        <dt class="mt-1 text-sm font-medium text-secondary-700">Engine</dt>
                        <dd class="text-sm text-secondary-500">${vehicle.engine / 10}%</dd>
                    </dl>
                    <div class="relative flex h-2 w-full overflow-hidden rounded-full bg-slate-700">
                        <div role="progressbar" aria-valuenow="${vehicle.engine / 10}" aria-valuemin="0" aria-valuemax="100" style="width: ${vehicle.engine / 10}%" class="flex h-full items-center justify-center bg-blue-300 text-white"></div>
                    </div>
                    <dl class="flex items-center justify-between">
                        <dt class="mt-1 text-sm font-medium text-secondary-700">Body</dt>
                        <dd class="text-sm text-secondary-500">${vehicle.body / 10}%</dd>
                    </dl>
                    <div class="relative flex h-2 w-full overflow-hidden rounded-full bg-slate-700">
                        <div role="progressbar" aria-valuenow="${vehicle.body / 10}" aria-valuemin="0" aria-valuemax="100" style="width: ${vehicle.body / 10}%" class="flex h-full items-center justify-center bg-green-300 text-white"></div>
                    </div>
                </div>
                <button type="button" id="drive-${index}" class="mt-5 rounded-md border-gray-700 bg-slate-700 px-2.5 py-1.5 text-center text-sm font-medium text-white transition-all hover:bg-green-300 hover:text-green-800 disabled:cursor-not-allowed disabled:border-gray-300 disabled:bg-gray-300">Drive Vehicle</button>
                <button type="button" id="swap-${index}" class="ml-2 rounded-md border-gray-700 bg-slate-700 px-2.5 py-1.5 text-center text-sm font-medium text-white transition-all hover:bg-green-300 hover:text-green-800 disabled:cursor-not-allowed disabled:border-gray-300 disabled:bg-gray-300">Swap Garages</button>
                <button type="button" id="transfer-${index}" class="ml-2 rounded-md border-gray-700 bg-slate-700 px-2.5 py-1.5 text-center text-sm font-medium text-white transition-all hover:bg-green-300 hover:text-green-800 disabled:cursor-not-allowed disabled:border-gray-300 disabled:bg-gray-300">Transfer Vehicle</button>                            
            `;
            $('.vehicle-container').append(vehicleHtml);

            $(`#drive-${index}`).on('click', function(event) {
                driveVehicle(vehicle);
            });

            $(`#swap-${index}`).on('click', function(event) {
                currentVehicle = vehicle;
                $('.garage-container').css('display', 'none')
                $.each(garages, function (index, value) {
                    if (value.label && value.canTransfer) {
                        $("#garageSelect").append('<option value="' + (index) + '">' + value.label + '</option>');
                    }
                });
                $('.swap-container').css('display', 'block')
            });

            $(`#transfer-${index}`).on('click', function(event) {
                $('.garage-container').css('display', 'none')
                currentVehicle = vehicle;
                $('.transfer-container').css('display', 'block')
            });
        });
    }
});

$("#confirm-transfer").click(function () {
    let id = $("#transfervehicle").val();
    $.post(`https://${GetParentResourceName()}/transfer`, JSON.stringify({
        vehicle: currentVehicle,
        id: id
    }));
    close()
});

$("#confirm-swap").click(function () {
    let garage = $("#garageSelect").val();
    $.post(`https://${GetParentResourceName()}/swap`, JSON.stringify({
        vehicle: currentVehicle,
        garage: garage
    }));
    close()
});

function driveVehicle(vehicle) {
    $('.garage-container').css('display', 'none')
    $.post(`https://${GetParentResourceName()}/takeOut`, JSON.stringify({
        vehicle: vehicle
    }));
}
document.onkeyup = function (data) {
    if (data.which == 27) {
        close()
        $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
    }
};

function close() {
    $('.garage-container').css('display', 'none')
    $('.swap-container').css('display', 'none')
    $('.transfer-container').css('display', 'none')
}