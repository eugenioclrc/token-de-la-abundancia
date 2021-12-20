<script>
    import { wrongNetwork, init, login, changeNetwork, wallet } from '../../store/index';
    import { onMount } from 'svelte';

    onMount(() => {
        init();
    });

	let isOpen = false;
</script>

    <header class="bg-gray-800">
        <nav class="container px-6 py-4 mx-auto md:flex md:justify-between md:items-center">
            <div class="flex items-center justify-between">
                <a class="text-xl font-bold text-white transition-colors duration-300 transform md:text-2xl hover:text-indigo-400"
                    href="/">El token de la abundancia</a>
    
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
                    href="/app">Listado</a>
                {#if $wrongNetwork}
                    <button class="px-4 py-1 text-sm font-medium text-center text-gray-200 transition-colors duration-300 transform border rounded hover:bg-indigo-400"
                    on:click={() => changeNetwork()}>Wrong network</button>
                {:else}
                    <span class="px-4 py-1 text-sm font-medium text-center text-gray-200 transition-colors duration-300 transform border rounded">
                        ROPSTEN
                    </span>

                {/if}
                {#if $wallet}
                <a class="px-4 py-1 text-sm font-medium text-center text-gray-200 transition-colors duration-300 transform border rounded hover:bg-indigo-400"
                    href="/app/holdings">{$wallet.slice(0,4)}...{$wallet.slice(-4)}</a>
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
                        on:click={() => changeNetwork()}>Cambiar a Ropsten</button>
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
    