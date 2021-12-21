<script>
    import { dev } from '$app/env';
    import { base } from '$app/paths';

    import { wrongNetwork, networkDetails, init, login, changeNetwork, wallet } from '../../store/index';
    import { onMount } from 'svelte';

    onMount(() => {
        init();
    });

    async function pickNetwork(n) {
        await changeNetwork(n);
        modalOpen = false;
    }

	let isOpen = false;
    let modalOpen = false;
</script>

{#if modalOpen}
  <div class="modal h-screen w-full fixed left-0 top-0 flex justify-center items-center bg-black bg-opacity-50 z-50">
    <!-- modal -->
    <div class="bg-white rounded shadow-lg w-10/12 md:w-1/3">
      <!-- modal header -->
      <div class="border-b px-4 py-2 flex justify-between items-center">
        <h3 class="font-semibold text-lg">Select a network</h3>
        <button class="text-black close-modal" on:click={() => modalOpen = false}>&cross;</button>
      </div>
      <!-- modal body -->
      <div class="p-3">
        Selecciona la red que quieres usar
      </div>
      <div class="flex justify-end items-center w-100 border-t p-3 flex-wrap">
        <!--
        <button class="bg-gray-600 hover:bg-gray-700 px-3 py-1 m-2 rounded text-white" on:click={() => pickNetwork('mumbai') }>
            {#if $networkDetails.chainId == 80001}&check;{/if} Mumbai MaticTest
        </button>
        <button class="bg-gray-600 hover:bg-gray-700 px-3 py-1 m-2 rounded text-white" on:click={() => pickNetwork('ropsten') }>
            {#if $networkDetails.chainId == 3}&check;{/if} Ropsten
        </button>
        -->
        <button class="bg-gray-600 hover:bg-gray-700 px-3 py-1 m-2 rounded text-white" on:click={() => pickNetwork('rinkeby') }>
            {#if $networkDetails.chainId == 4}&check;{/if}
            Rinkeby
        </button>
        {#if dev}
            <button class="bg-gray-600 hover:bg-gray-700 px-3 py-1 m-2 rounded text-white" on:click={() => pickNetwork('hardhat') }>
                {#if $networkDetails.chainId == 31337}&check;{/if}
                HardHat
            </button>
        {/if}
      </div>
    </div>
    </div>
{/if}
    <header class="bg-gray-800">
        <nav class="container px-6 py-4 mx-auto md:flex md:justify-between md:items-center">
            <div class="flex items-center justify-between">
                <a class="text-xl font-bold text-white transition-colors duration-300 transform md:text-2xl hover:text-indigo-400"
                    href="{base}/">El token de la abundancia</a>
    
                <!-- Mobile menu button -->
                <div on:click={() => isOpen = !isOpen} class="flex md:hidden">
                    <button type="button" class="text-gray-200 hover:text-gray-400 focus:outline-none focus:text-gray-400"
                        aria-label="toggle menu">
                        <svg viewBox="0 0 24 24" class="w-6 h-6 fill-current">
                            <path fill-rule="evenodd"
                                d="M4 5h16a1 1 0 0 1 0 2H4a1 1 0 1 1 0-2zm0 6h16a1 1 0 0 1 0 2H4a1 1 0 0 1 0-2zm0 6h16a1 1 0 0 1 0 2H4a1 1 0 0 1 0-2z">
                            </path>
                        </svg>
                    </button>
                </div>
            </div>
    
            <!-- Mobile Menu open: "block", Menu closed: "hidden" -->
            <div
                class="flex-col mt-2 space-y-4 md:flex md:space-y-0 md:flex-row md:items-center md:space-x-10 md:mt-0
								{isOpen ? 'flex' : 'hidden'}">
                <a class="text-sm font-medium text-gray-200 transition-colors duration-300 transform hover:text-indigo-400"
                    href="{base}/app">Listado</a>
                {#if $wrongNetwork}
                    <button class="px-4 py-1 text-sm font-medium text-center text-gray-200 transition-colors duration-300 transform border rounded hover:bg-indigo-400 uppercase"
                    on:click={() => modalOpen = true}>{$networkDetails && $networkDetails.name} - Wrong network</button>
                {:else}
                    <span class="px-4 py-1 text-sm font-medium text-center text-gray-200 transition-colors duration-300 transform border rounded cursor-pointer hover:bg-indigo-400 uppercase" on:click={() => modalOpen = true}>
                        {$networkDetails && $networkDetails.name}
                    </span>
                {/if}
                {#if $wallet}
                    <a class="px-4 py-1 text-sm font-medium text-center text-gray-200 transition-colors duration-300 transform border rounded hover:bg-indigo-400"
                        href="{base}/app/holdings">{$wallet.slice(0,4)}...{$wallet.slice(-4)}</a>
                {/if}
            </div>
        </nav>
        
        {#if $wrongNetwork}
          <section class="flex items-center justify-center flex-col" style="height: 500px;">
            <div class="text-center">
                <p class="text-xl font-medium tracking-wider text-gray-300">El token NFT de la abundancia</p>
                <h2 class="mt-6 text-3xl font-bold text-white md:text-5xl">Estas en una red incorrecta</h2>
    
                <div class="flex justify-center mt-8">
                    <button class="m-2 px-8 py-2 text-lg font-medium bg-white transition-colors duration-300 transform text-indigo-600 rounded hover:text-indigo-500"
                        on:click={() => modalOpen = true }>Cambiar de Red</button>
                </div>
            </div>   
          </section>
        {/if}
        {#if !$wallet}
          <section class="flex items-center justify-center flex-col" style="height: 500px;">
            <div class="text-center">
                <p class="text-xl font-medium tracking-wider text-gray-300">El token NFT de la abundancia</p>
                <h2 class="mt-6 text-3xl font-bold text-white md:text-5xl">Conecta tu waller usando metamask</h2>
    
                <div class="flex justify-center mt-8">
                    <button class="m-2 px-8 py-2 text-lg font-medium bg-white transition-colors duration-300 transform text-indigo-600 rounded hover:text-indigo-500"
                        on:click={() => login()}>Conectar con metamask</button>
                </div>
            </div>   
          </section>
        {/if}
    </header>
    {#if !$wrongNetwork && $wallet}
        <slot />
    {/if}
    